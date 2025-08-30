#!/bin/bash

# Hentikan eksekusi jika ada perintah yang gagal
set -e

echo "===== MENAIKKAN VERSI PATCH DI pom.xml LOKAL ====="

# Jalankan perintah Maven untuk menaikkan versi patch (misal: 0.0.1 -> 0.0.2)
# Perintah ini akan mengubah file pom.xml di direktori Anda.
mvn build-helper:parse-version versions:set \
    -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion} \
    versions:commit

# Baca versi baru dari pom.xml untuk digunakan sebagai tag
# (Membutuhkan Maven untuk dijalankan dua kali, tapi ini cara termudah di bash)
NEW_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

echo ""
echo "Versi berhasil dinaikkan ke: $NEW_VERSION"
echo ""
echo "===== MEMBANGUN DOCKER IMAGE DENGAN VERSI BARU ====="

# Jalankan docker compose untuk membangun image dengan tag versi baru
# dan menjalankan container di background.
docker-compose build
docker-compose up -d

echo ""
echo "===== SELESAI ====="
echo "Aplikasi berjalan dengan versi $NEW_VERSION di http://localhost:8080"
