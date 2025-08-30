# --- Stage 1: Build & Version Increment ---
# Gunakan base image yang memiliki Maven dan JDK 21
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /app

# Salin pom.xml terlebih dahulu untuk caching
COPY pom.xml .

# --- BAGIAN UTAMA: MENAIKKAN VERSI ---
# Perintah ini membaca versi saat ini, menaikkannya,
# dan memperbarui pom.xml HANYA di dalam container build ini.
#RUN mvn build-helper:parse-version versions:set \
#    -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion} \
#    versions:commit

# Unduh semua dependency berdasarkan pom.xml yang versinya sudah naik
RUN mvn dependency:go-offline

# Salin sisa kode sumber proyek
COPY src ./src

# Bangun aplikasi (JAR) menggunakan versi yang sudah dinaikkan.
RUN mvn clean package -DskipTests

# --- Stage 2: Final Image (Runtime) ---
# **PERBAIKAN:** Gunakan base image JRE 21 yang valid dari Eclipse Temurin
FROM eclipse-temurin:21-jre

WORKDIR /app

# ARG ini diperlukan untuk mencari nama file JAR secara dinamis
ARG JAR_FILE_PATH=target/demo-*.jar

# Salin file JAR yang sudah di-build dari stage 'builder'
COPY --from=builder /app/${JAR_FILE_PATH} app.jar

# Expose port yang digunakan aplikasi
EXPOSE 8080

# Perintah untuk menjalankan aplikasi saat container dimulai
ENTRYPOINT ["java", "-jar", "app.jar"]

