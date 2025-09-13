@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: NetBackup Master Server Bilgileri
set NB_SERVER=win-t89q8gl89g1
set NB_PORT=1556
set DB_FILE=netbackup.db
set NB_WEBSERVICE=nbwebsvc

:: Veritabanında kayıtlı API key'i kontrol et
echo Veritabanindaki API Key kontrol ediliyor...
sqlite3 %DB_FILE% "SELECT api_key FROM api_keys WHERE username='%NB_WEBSERVICE%' ORDER BY id DESC LIMIT 1;" > db_api_key.txt 2>nul

set /p DB_API_KEY=<db_api_key.txt 2>nul

if not "!DB_API_KEY!"=="" (
    echo Veritabanindaki API Key bulundu: !DB_API_KEY!
    echo !DB_API_KEY! > current_api_key.txt
    echo API Key current_api_key.txt dosyasina kaydedildi.
    goto success
)

:: API Key yoksa, yeni bir tane oluştur
echo API Key olusturuluyor...
echo.

:: Önce token kontrol et
if not exist token.txt (
    echo Token bulunamadi! Login yapiliyor...
    call login_and_save.bat
)

set /p JWT_TOKEN=<token.txt

:: Yeni API Key oluşturma isteği
set URL=https://%NB_SERVER%:%NB_PORT%/netbackup/security/api-keys
curl -k -X POST "%URL%" ^
  -H "Content-Type: application/vnd.netbackup+json;version=11.0" ^
  -H "Authorization: %JWT_TOKEN%" ^
  -d "{\"data\":{\"type\": \"apiKeyCreationRequest\",\"attributes\":{\"expireAfterDays\":\"P30D\",\"description\":\"API key for automation scripts\"}}}" ^
  -o response_api_key.json

echo API Yaniti:
type response_api_key.json
echo.

:: API Key'i çek
for /f "tokens=*" %%i in ('jq -r ".data.attributes.apiKey" response_api_key.json 2^>nul') do set "API_KEY=%%i"
for /f "tokens=*" %%i in ('jq -r ".data.attributes.expiryDateTime" response_api_key.json 2^>nul') do set "EXPIRY_DATE=%%i"

if "!API_KEY!"=="" (
    echo HATA: API Key alinamadi!
    goto cleanup
)

echo BASARILI: API Key alindi!
echo API Key: !API_KEY!
echo Expiry Date: !EXPIRY_DATE!

:: JSON yanıtını dosyadan oku
set "JSON_RESPONSE="
for /f "usebackq tokens=*" %%i in ("response_api_key.json") do (
    set "line=%%i"
    set "JSON_RESPONSE=!JSON_RESPONSE!!line!"
)

:: Tırnak işaretlerini escape et
set "JSON_RESPONSE=!JSON_RESPONSE:"='!"

:: API Key'i veritabanına kaydet
sqlite3 %DB_FILE% "INSERT INTO api_keys (username, api_key, description, expiry_date, raw_response) VALUES ('%NB_WEBSERVICE%', '!API_KEY!', 'Automation API Key', '!EXPIRY_DATE!', '!JSON_RESPONSE!');"

:: API Key'i dosyaya kaydet
echo !API_KEY! > current_api_key.txt
echo API Key current_api_key.txt dosyasina kaydedildi.

:success
echo.
echo ISLEM TAMAMLANDI!
echo.

:: Son API Key kaydını göster
sqlite3 -header -column %DB_FILE% "SELECT id, username, substr(api_key, 1, 20) || '...' as api_key_preview, expiry_date FROM api_keys ORDER BY id DESC LIMIT 1;"

echo.
echo Guncel API Key:
if exist current_api_key.txt (
    type current_api_key.txt
) else (
    echo API Key bulunamadi!
)

:cleanup
:: Temizlik
del response_api_key.json 2>nul
del db_api_key.txt 2>nul

echo.
pause