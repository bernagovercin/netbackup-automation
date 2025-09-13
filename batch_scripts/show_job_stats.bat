@echo off
chcp 65001 > nul
setlocal

set DB_FILE=netbackup.db

echo.
echo ===== JOB ISTATISTIKLER =====
echo.

echo TOPLAM JOB KAYDI:
sqlite3 %DB_FILE% "SELECT COUNT(*) FROM job_logs;"

echo.

echo BENZERSIZ JOB SAYISI:
sqlite3 %DB_FILE% "SELECT COUNT(DISTINCT job_id) FROM job_logs;"

echo.

echo ILK KAYIT:
sqlite3 %DB_FILE% "SELECT MIN(datetime(request_time)) FROM job_logs;"

echo.

echo SON KAYIT:
sqlite3 %DB_FILE% "SELECT MAX(datetime(request_time)) FROM job_logs;"

echo.

echo SON 5 ISLEM:
sqlite3 -header -column %DB_FILE% "SELECT job_id, datetime(request_time) as Zaman FROM job_logs ORDER BY request_time DESC LIMIT 5;"

echo.
echo NOT: JSON verileri ham olarak kaydedildigi icin detay istatistikler veritabaninda.
echo      Istersen raw_response alanina bakabilirsin.
echo.

pause