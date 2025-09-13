@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

set DB_FILE=netbackup.db

echo KATALOG RAPORU
echo ==============
echo.

echo 1. Toplam Image Sayisi:
sqlite3 %DB_FILE% "SELECT COUNT(*) as 'Toplam Image' FROM catalog_images;"

echo.
echo 2. Son 10 Image:
sqlite3 -header -column %DB_FILE% "SELECT image_id, client_name, policy_name, status FROM catalog_images ORDER BY rowid DESC LIMIT 10;"

echo.
echo 3. Policy'lere Gore Dagilim:
sqlite3 -header -column %DB_FILE% "SELECT policy_name, COUNT(*) as adet FROM catalog_images GROUP BY policy_name;"

echo.
echo 4. Status Dagilimi:
sqlite3 -header -column %DB_FILE% "SELECT status, COUNT(*) as adet FROM catalog_images GROUP BY status;"

echo.
echo 5. Client'lara Gore Dagilim:
sqlite3 -header -column %DB_FILE% "SELECT client_name, COUNT(*) as adet FROM catalog_images GROUP BY client_name;"

echo.
pause