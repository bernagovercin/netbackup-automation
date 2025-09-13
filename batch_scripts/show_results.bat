@echo off
chcp 65001 > nul
setlocal

set DB_FILE=netbackup.db

echo ====================================
echo NETBACKUP VERITABANI SONUCLARI
echo ====================================
echo.

echo Kayitli Hostlar:
echo ---------------
sqlite3 -header -column %DB_FILE% "SELECT host_uuid, host_name, os_type FROM hosts;"

echo.
pause