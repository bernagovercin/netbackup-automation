@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: NetBackup Master Server Bilgileri
set NB_WEBSERVICE=nbwebsvc
set NB_PASSWORD=Raplife123.
set NB_SERVER=win-t89q8gl89g1
set NB_PORT=1556
set DB_FILE=netbackup.db

:: API'nin tam adresi
set URL=https://%NB_SERVER%:%NB_PORT%/netbackup/login

echo NetBackup API'sine login olunuyor...
echo URL: %URL%
echo.

:: Kimlik doğrulama isteğini gönder
curl -k -X POST %URL% ^
  -H "Content-Type: application/vnd.netbackup+json;version=11.0" ^
  -d "{\"domainType\":\"nt\", \"domainName\":\"%NB_SERVER%\", \"userName\":\"%NB_WEBSERVICE%\", \"password\":\"%NB_PASSWORD%\"}" ^
  -o response_login.json

echo.
echo API Yaniti:
type response_login.json
echo.

:: JSON yanıtını bir değişkene oku (tüm satırları birleştir)
set "JSON_RESPONSE="
for /f "tokens=*" %%i in (response_login.json) do set "JSON_RESPONSE=!JSON_RESPONSE!%%i"

:: jq ile token'ı çıkarmaya çalış
jq -r ".token" response_login.json > token.txt

set /p TOKEN=<token.txt

if "%TOKEN%"=="null" (
    echo HATA: Token alinamadi!
    
    :: BAŞARISIZ login kaydı
    sqlite3 %DB_FILE% "INSERT INTO login_logs (raw_response) VALUES ('%JSON_RESPONSE%');"
    
    :: Token dosyasını sil
    del token.txt 2>nul
) else (
    echo BASARILI: Token alindi!
    
    :: BAŞARILI login kaydı
    sqlite3 %DB_FILE% "INSERT INTO login_logs (raw_response) VALUES ('%JSON_RESPONSE%');"
    
    echo Token token.txt dosyasina kaydedildi.
)

:: Temizlik
del response_login.json 2>nul

echo.
echo VERITABANI KAYDI TAMAMLANDI!
echo.

:: Son login kaydını göster
sqlite3 -header -column %DB_FILE% "SELECT id, login_time, length(raw_response) as response_length FROM login_logs ORDER BY id DESC LIMIT 1;"

echo.
pause