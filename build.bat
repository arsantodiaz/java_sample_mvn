@echo off
setlocal

echo ===== MENAIKKAN VERSI PATCH DI pom.xml LOKAL =====

:: Jalankan perintah Maven untuk menaikkan versi patch (misal: 0.0.1 -> 0.0.2)
:: PERBAIKAN: Perintah ini disederhanakan agar lebih andal di Windows.
call mvn build-helper:parse-version versions:set -DnewVersion=${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion}

:: Periksa apakah perintah Maven berhasil
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Gagal saat mencoba menaikkan versi Maven.
    exit /b %ERRORLEVEL%
)

:: Hapus file backup yang dibuat oleh versions-maven-plugin
if exist pom.xml.versionsBackup del pom.xml.versionsBackup

:: Baca versi baru dari pom.xml untuk digunakan sebagai tag
echo.
echo Sedang membaca versi baru dari pom.xml...

:: PERBAIKAN: Gunakan file temporer untuk menangkap output agar lebih andal
set "MVN_OUTPUT_FILE=%TEMP%\mvn_version_output.txt"
call mvn help:evaluate -Dexpression=project.version -q -DforceStdout > "%MVN_OUTPUT_FILE%"

:: Periksa apakah perintah Maven untuk mendapatkan versi berhasil
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Gagal saat mencoba membaca versi baru dari pom.xml.
    if exist "%MVN_OUTPUT_FILE%" del "%MVN_OUTPUT_FILE%"
    exit /b %ERRORLEVEL%
)

:: Baca versi dari file temporer dan hapus file tersebut
set /p NEW_VERSION=<"%MVN_OUTPUT_FILE%"
del "%MVN_OUTPUT_FILE%"

:: Periksa apakah variabel NEW_VERSION berhasil di-set
if not defined NEW_VERSION (
    echo.
    echo ERROR: Tidak dapat mendeteksi versi baru. Pastikan Maven dikonfigurasi dengan benar.
    exit /b 1
)


echo.
echo Versi berhasil dinaikkan ke: %NEW_VERSION%
echo.
echo ===== MEMBANGUN DOCKER IMAGE DENGAN VERSI BARU =====

:: Jalankan docker-compose untuk membangun image
call docker-compose build
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Gagal saat membangun image Docker.
    exit /b %ERRORLEVEL%
)

:: Jalankan container di background
call docker-compose up -d
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Gagal saat menjalankan container Docker.
    exit /b %ERRORLEVEL%
)

echo.
echo ===== SELESAI =====
echo Aplikasi berjalan dengan versi %NEW_VERSION% di http://localhost:8080


echo.
echo ===== MENGKOMIT PERUBAHAN DI pom.xml =====
git add pom.xml
git commit -m "chore: bump patch version to %NEW_VERSION%"
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Gagal mengkomit perubahan pom.xml.
    exit /b %ERRORLEVEL%
)
echo.
endlocal

