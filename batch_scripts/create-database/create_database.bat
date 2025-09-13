@echo off
chcp 65001 > nul
setlocal

set DB_FILE=netbackup.db

echo Veritabani olusturuluyor: %DB_FILE%
echo.

:: Sadece ham JSON yanıtını tutacak tablo
sqlite3 %DB_FILE% "CREATE TABLE IF NOT EXISTS login_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, login_time DATETIME DEFAULT CURRENT_TIMESTAMP, raw_response TEXT);"

echo Login logs tablosu olusturuldu.
echo.

:: Tablo yapısını göster
sqlite3 -header -column %DB_FILE% "PRAGMA table_info(login_logs);"

echo.
echo Veritabani basariyla olusturuldu: %DB_FILE%
pause