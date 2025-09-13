:: analyze_catalog_response.bat
@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo API Response Analizi
echo ===================
echo.

:: API Key kontrolü
if not exist current_api_key.txt (
    echo API Key bulunamadi!
    call create_api_key.bat
)
set /p API_KEY=<current_api_key.txt

set NB_SERVER=win-t89q8gl89g1
set NB_PORT=1556
set URL=https://%NB_SERVER%:%NB_PORT%/netbackup/catalog/images?page%5Blimit%5D=10

echo API cagrisi yapiliyor...
curl -k -X GET "!URL!" ^
  -H "Accept: application/vnd.netbackup+json;version=11.0" ^
  -H "Authorization: !API_KEY!" ^
  -o catalog_images_response.json

echo.
echo 1. Toplam image sayisi:
jq ".data | length" catalog_images_response.json 2>nul || echo "jq komutu calismadi"

echo.
echo 2. Ilk image'in detaylari:
jq ".data[0] | {id: .id, clientName: .attributes.clientName, policyName: .attributes.policyName, backupTime: .attributes.backupTime, status: .attributes.backupStatus}" catalog_images_response.json 2>nul || echo "JSON parse edilemedi"

echo.
echo 3. Response ornegi:
head -n 5 catalog_images_response.json

echo.
echo 4. HTTP Status kodlari:
curl -k -o nul -w "%%{http_code}" -X GET "!URL!" ^
  -H "Accept: application/vnd.netbackup+json;version=11.0" ^
  -H "Authorization: !API_KEY!"

echo.
echo.
pause