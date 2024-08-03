@echo off
REM Klasor yollarını ayarlayın
SET BASE_DIR=C:\Users\EGEMEN\CODING\Library\Deployment
SET JAR_DIR=%BASE_DIR%\lib
SET WAR_DIR=%BASE_DIR%\war

REM Belirttiğiniz klasördeki tüm dosyaları sil
echo Siliniyor: %JAR_DIR%\*.jar
del /Q %JAR_DIR%\*.jar

REM Maven Wrapper kullanarak clean install işlemi başlat
echo Maven clean install baslatiliyor...
call mvnw clean install

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo Maven clean install basarisiz oldu.
    exit /b 1
)

REM Maven build işleminden sonra bağımlılıkları belirttiğiniz klasöre kopyalama
echo Bagimliliklar kopyalaniyor...
call mvnw dependency:copy-dependencies -DoutputDirectory=%JAR_DIR% -DincludeScope=runtime -DoverWrite=true

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo Bagimliliklarin kopyalanmasi basarisiz oldu.
    exit /b 1
)

REM Oluşan WAR dosyasını war klasörüne taşı
echo WAR dosyasi tasiniyor...
move /Y target\*.war %WAR_DIR%

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo WAR dosyasinin tasinmasi basarisiz oldu.
    exit /b 1
)

echo Islem basariyla tamamlandi.
exit /b 1
