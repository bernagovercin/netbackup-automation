@echo off
chcp 65001 > nul
echo ====================================
echo NETBACKUP API OTOMASYON SISTEMI
echo ====================================
echo.

:menu
echo 1.  Login Ol ve Token Al
echo 2.  API Key Olustur (30 gunluk)
echo 3.  Tum Job'lari Veritabanina Kaydet
echo 4.  Job Istatistiklerini Goster
echo 5.  Katalog Raporu Goster
echo 6.  API Key'leri Goster
echo 7.  Veritabani Olustur (Ilk kurulum)
echo 8.  Cikis
echo.
choice /c 123456789 /n /m "Seciminiz: "

if %errorlevel% equ 1 goto login
if %errorlevel% equ 2 goto use_api_key
if %errorlevel% equ 3 goto get_jobs
if %errorlevel% equ 4 goto show_stats
if %errorlevel% equ 5 goto catalog_report
if %errorlevel% equ 6 goto show_api
if %errorlevel% equ 7 goto create_db
if %errorlevel% equ 8 goto exit

:login
echo.
call login_and_save.bat
goto menu

:use_api_key
echo.
call use_api_key.bat
goto menu


:get_jobs
echo.
call get_all_jobs_to_db.bat
goto menu

:show_stats
echo.
call show_job_stats.bat
goto menu

:catalog_report
echo.
call check_status_fixed.bat
goto menu

:show_api
echo.
sqlite3 -header -column netbackup.db "SELECT id, username, created_at, expiry_date, substr(api_key, 1, 20) || '...' as api_key_preview FROM api_keys ORDER BY created_at DESC;"
pause
goto menu

:create_db
echo.
call create_database.bat
goto menu

:exit
echo.
echo Program sonlandirildi.
pause