@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: NetBackup Master Server Bilgileri
set NB_SERVER=win-t89q8gl89g1
set NB_PORT=1556
set DB_FILE=netbackup.db

echo ====================================
echo TUM JOBS VERITABANINA KAYDEDILIYOR
echo ====================================
echo.

:: Önce token kontrol et
if not exist token.txt (
    echo Token bulunamadi! Login yapiliyor...
    call login_and_save.bat
)

set /p JWT_TOKEN=<token.txt

:: API'nin tam adresi
set URL=https://%NB_SERVER%:%NB_PORT%/netbackup/admin/jobs

echo Tum job listesi aliniyor...
echo.

:: Tüm jobs isteğini gönder
curl -k -X GET %URL% ^
  -H "Accept: application/vnd.netbackup+json;version=11.0" ^
  -H "Authorization: %JWT_TOKEN%" ^
  -o response_all_jobs.json

echo.

:: JSON'dan sadece job ID'leri çekelim
jq -r ".data[].id" response_all_jobs.json > job_ids.txt 2>nul

:: Kaç tane job var?
set JOB_COUNT=0
for /f %%i in ('type job_ids.txt 2^>nul ^| find /c /v ""') do set JOB_COUNT=%%i

echo TOPLAM JOB SAYISI: !JOB_COUNT!
echo.

:: Veritabanında zaten kayıtlı job'ları kontrol et
sqlite3 %DB_FILE% "SELECT job_id FROM job_logs;" > existing_jobs.txt 2>nul

echo Kayitli joblar kontrol ediliyor...
echo.

set NEW_JOBS=0

:: Her job ID için bilgi çek ve kaydet (sadece yeni olanları)
for /f "tokens=*" %%i in (job_ids.txt) do (
    find "%%i" existing_jobs.txt >nul 2>&1
    if errorlevel 1 (
        echo YENI JOB: %%i bilgisi aliniyor...
        call :get_job_info %%i
        set /a NEW_JOBS+=1
    ) else (
        echo Job ID %%i zaten kayitli.
    )
)

echo.
if !NEW_JOBS! equ 0 (
    echo Yeni job bulunamadi.
) else (
    echo !NEW_JOBS! yeni job veritabanina kaydedildi.
)

:: Tüm job sayısını güncelle
sqlite3 %DB_FILE% "SELECT COUNT(DISTINCT job_id) FROM job_logs;" > total_jobs.txt 2>nul
set /p TOTAL_JOBS=<total_jobs.txt

echo.
echo VERITABANINDAKI TOPLAM JOB SAYISI: !TOTAL_JOBS!
echo.

:: Temizlik
del response_all_jobs.json 2>nul
del job_ids.txt 2>nul
del existing_jobs.txt 2>nul
del total_jobs.txt 2>nul

echo ====================================
echo ISLEM TAMAMLANDI!
echo ====================================
pause
exit /b

:get_job_info
setlocal
set JOB_ID=%~1

:: API'nin tam adresi
set JOB_URL=https://%NB_SERVER%:%NB_PORT%/netbackup/admin/jobs/%JOB_ID%

:: Job bilgisi isteğini gönder
curl -k -X GET %JOB_URL% ^
  -H "Accept: application/vnd.netbackup+json;version=11.0" ^
  -H "Authorization: %JWT_TOKEN%" ^
  -o response_job_%JOB_ID%.json

:: JSON yanıtını bir değişkene oku
set "JSON_RESPONSE="
for /f "tokens=*" %%j in (response_job_%JOB_ID%.json) do set "JSON_RESPONSE=!JSON_RESPONSE!%%j"

:: JSON'daki tırnak işaretlerini escape et
set "JSON_RESPONSE=!JSON_RESPONSE:'=''!"

:: Ham JSON yanıtını veritabanına kaydet
sqlite3 %DB_FILE% "INSERT INTO job_logs (job_id, raw_response) VALUES (%JOB_ID%, '%JSON_RESPONSE%');"

:: Temizlik
del response_job_%JOB_ID%.json 2>nul

endlocal
exit /b