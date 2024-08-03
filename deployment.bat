@echo off
echo ***** BY EGEMEN SENER *****
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

REM Mevcut tarih ve saati al ve formatla
set year=%date:~-4%
set month=%date:~4,2%
set day=%date:~7,2%
set hour=%time:~0,2%
if %hour% lss 10 set hour=0%hour:~-1%
set minute=%time:~3,2%

REM Tarih ve saat formatını ayarla
set formattedDate=%year%%month%%day%-%hour%%minute%

REM WAR dosyasını zipleyin ve war klasörüne koyun
echo WAR dosyasi zipleniyor...
powershell Compress-Archive -Path "%WAR_DIR%\library.war" -DestinationPath "%WAR_DIR%\%formattedDate%-library-war.zip"

REM WAR dosyasını sil
del /Q %WAR_DIR%\library.war

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo WAR dosyasinin ziplenmesi basarisiz oldu.
    exit /b 1
)

echo ***** Deployment Dosyasi Hazir *****
exit /b 1
