@echo off
chcp 65001 > nul
setlocal

set DB_FILE=netbackup.db

echo Veritabani guncelleniyor: %DB_FILE%
echo.

:: Jobs tablosunu oluştur
sqlite3 %DB_FILE% "CREATE TABLE IF NOT EXISTS job_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, job_id INTEGER, request_time DATETIME DEFAULT CURRENT_TIMESTAMP, raw_response TEXT);"

echo Job logs tablosu olusturuldu.
echo.

:: Tablo yapısını göster
sqlite3 -header -column %DB_FILE% "PRAGMA table_info(job_logs);"

echo.
echo Veritabani basariyla guncellendi: %DB_FILE%
pause