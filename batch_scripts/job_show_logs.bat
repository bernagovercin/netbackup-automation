@echo off
chcp 65001 > nul
setlocal

set DB_FILE=netbackup.db

echo.
echo ===== JOB LOGLARI =====
echo.

:: Tüm job kayıtlarını göster
sqlite3 -header -column %DB_FILE% "SELECT id, job_id, request_time, substr(raw_response, 1, 50) || '...' as preview FROM job_logs ORDER BY request_time DESC;"

echo.
echo Toplam job kayit sayisi: 
sqlite3 %DB_FILE% "SELECT COUNT(*) FROM job_logs;"

echo.
echo Tam JSON'i gormek icin:
echo sqlite3 %DB_FILE% "SELECT raw_response FROM job_logs WHERE id = X;"
echo.

pause