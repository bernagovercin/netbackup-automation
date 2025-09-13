@echo off
chcp 65001 > nul
setlocal

set DB_FILE=netbackup.db

echo.
echo ===== HAM JSON LOGLARI =====
echo.

:: Tüm login kayıtlarını göster
sqlite3 -header -column %DB_FILE% "SELECT id, login_time, substr(raw_response, 1, 50) || '...' as preview FROM login_logs ORDER BY login_time DESC;"

echo.
echo Toplam kayit sayisi: 
sqlite3 %DB_FILE% "SELECT COUNT(*) FROM login_logs;"

echo.
echo Tam JSON'i gormek icin:
echo sqlite3 %DB_FILE% "SELECT raw_response FROM login_logs WHERE id = X;"
echo.

pause