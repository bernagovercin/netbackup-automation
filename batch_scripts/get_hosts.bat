@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

set NB_SERVER=win-t89q8gl89g1
set NB_PORT=1556
set DB_FILE=netbackup.db

echo Host listesi aliniyor...
echo.

if not exist current_api_key.txt (
    echo API Key bulunamadi! Once API Key olusturun.
    call create_api_key.bat
)

set /p API_KEY=<current_api_key.txt

set URL=https://%NB_SERVER%:%NB_PORT%/netbackup/config/hosts

curl -k -X GET "%URL%" ^
  -H "Accept: application/vnd.netbackup+json;version=11.0" ^
  -H "Authorization: %API_KEY%" ^
  -o response_hosts.json

echo API Yaniti:
type response_hosts.json
echo.

:: JSON'dan host bilgilerini çek
jq -r ".hosts[] | \"\(.uuid),\(.hostName),\(.osType),\(.nbuVersion)\"" response_hosts.json > host_list.txt

echo Bulunan Hostlar:
echo ---------------
type host_list.txt

:: Veritabanına kaydet
for /f "tokens=1-4 delims=," %%a in (host_list.txt) do (
    sqlite3 %DB_FILE% "INSERT INTO hosts (host_uuid, host_name, os_type, nbu_version) VALUES ('%%a', '%%b', '%%c', '%%d');"
)

del response_hosts.json
echo.
echo Hostlar veritabanina kaydedildi!
pause