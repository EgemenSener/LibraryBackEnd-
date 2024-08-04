@echo off
echo ***** BY EGEMEN SENER *****
REM Klasor yollarını ayarlayın
SET BASE_DIR=C:\Users\EGEMEN\CODING\Library\Deployment
SET JAR_DIR=%BASE_DIR%\lib
SET TEMP_JAR_DIR=%BASE_DIR%\temp_lib
SET WAR_DIR=%BASE_DIR%\war

REM Temp klasörü oluştur veya var olanı temizle
if exist %TEMP_JAR_DIR% (
    rmdir /S /Q %TEMP_JAR_DIR%
)
mkdir %TEMP_JAR_DIR%

REM lib klasöründeki dosyaları geçici klasöre taşı
echo lib klasöründeki dosyalar temp_lib'e taşınıyor...
move /Y %JAR_DIR%\*.jar %TEMP_JAR_DIR%

REM Maven Wrapper kullanarak clean install işlemi başlat
echo Maven clean install başlatiliyor...
call mvnw clean install

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo Maven clean install basarisiz oldu.
    exit /b 1
)

REM Yeni oluşan WAR'ın içindeki JAR dosyalarını lib klasörüne taşı
echo Yeni JAR dosyaları lib klasörüne taşınıyor...
call mvnw dependency:copy-dependencies -DoutputDirectory=%JAR_DIR% -DincludeScope=runtime -DoverWrite=true

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo Bagimliliklarin kopyalanmasi basarisiz oldu.
    exit /b 1
)

REM Temp klasör ile lib klasörü arasındaki farkları bul ve WAR klasörüne kopyala
echo Farklı JAR dosyaları tespit ediliyor ve WAR klasörüne taşınıyor...
for %%f in (%JAR_DIR%\*.jar) do (
    if not exist "%TEMP_JAR_DIR%\%%~nxf" (
        copy "%%f" "%WAR_DIR%"
    )
)

REM Oluşan WAR dosyasını war klasörüne taşı
echo WAR dosyası taşınıyor...
move /Y target\*.war %WAR_DIR%\library.war

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo WAR dosyasının taşınması başarısız oldu.
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

REM Farklı JAR dosyalarını ve WAR dosyasını zipleyin
echo WAR dosyası ve yeni JAR'lar zipleniyor...
powershell Compress-Archive -Path "%WAR_DIR%\library.war", "%WAR_DIR%\*.jar" -DestinationPath "%WAR_DIR%\%formattedDate%-library-war.zip"

REM WAR dosyasını ve fark dosyalarını sil
del /Q %WAR_DIR%\library.war
del /Q %WAR_DIR%\*.jar

REM Temp klasörü temizle
rmdir /S /Q %TEMP_JAR_DIR%

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo WAR dosyasının ziplenmesi başarısız oldu.
    exit /b 1
)

echo ***** Deployment Dosyasi Hazir *****
exit /b 0
