@echo off
echo ***** BY EGEMEN SENER *****
REM Klasor yollarını ayarlayın
SET BASE_DIR=C:\Users\EGEMEN\CODING\Library\Deployment
SET PACKAGES_DIR=%BASE_DIR%\packages
SET JAR_DIR=%BASE_DIR%\lib
SET TEMP_JAR_DIR=%BASE_DIR%\temp_lib
SET WAR_DIR=%BASE_DIR%\war

REM War klasörünün içeriğini temizle
echo WAR klasörünün içeriği temizleniyor...
if exist %WAR_DIR%\* (
    del /Q %WAR_DIR%\*
)

REM Virtualwarlib klasörünü temizle
if exist %WAR_DIR%\virtualwarlib (
    rmdir /S /Q %WAR_DIR%\virtualwarlib
)

REM Temp klasörü oluştur veya var olanı temizle
if exist %TEMP_JAR_DIR% (
    rmdir /S /Q %TEMP_JAR_DIR%
)
mkdir %TEMP_JAR_DIR%

REM lib klasöründeki dosyaları geçici klasöre taşı
echo lib klasöründeki dosyalar temp_lib'e taşınıyor...
move /Y %JAR_DIR%\*.jar %TEMP_JAR_DIR%

REM Maven Wrapper kullanarak clean install işlemi başlat
echo Maven clean install başlatılıyor...
call mvnw clean install

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo Maven clean install başarısız oldu.
    exit /b 1
)

REM Yeni oluşan WAR'ın içindeki JAR dosyalarını lib klasörüne taşı
echo Yeni JAR dosyaları lib klasörüne taşınıyor...
call mvnw dependency:copy-dependencies -DoutputDirectory=%JAR_DIR% -DincludeScope=runtime -DoverWrite=true

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo Bağımlılıkların kopyalanması başarısız oldu.
    exit /b 1
)

REM Temp klasör ile lib klasörü arasındaki farkları bul ve WAR klasörüne kopyala
echo Farklı JAR dosyaları tespit ediliyor ve WAR klasörüne taşınıyor...
set newJarFound=false
for %%f in (%JAR_DIR%\*.jar) do (
    if not exist "%TEMP_JAR_DIR%\%%~nxf" (
        copy "%%f" "%WAR_DIR%"
        set newJarFound=true
    )
)

REM Yeni eklenen JAR dosyaları varsa, virtualwarlib klasörünü oluştur ve dosyaları buraya taşı
if %newJarFound% == true (
    mkdir %WAR_DIR%\virtualwarlib
    move /Y %WAR_DIR%\*.jar %WAR_DIR%\virtualwarlib

    REM Virtualwarlib klasörünü zipleyin
    echo Virtualwarlib klasörü zipleniyor...
    powershell Compress-Archive -Path "%WAR_DIR%\virtualwarlib" -DestinationPath "%WAR_DIR%\virtualwarlib.zip"

    REM Virtualwarlib klasörünü silin
    rd /s /q %WAR_DIR%\virtualwarlib
)

REM Oluşan WAR dosyasını war klasörüne taşı
echo WAR dosyası taşınıyor...
if exist target\*.war (
    move /Y target\*.war %WAR_DIR%\library.war
) else (
    echo Hata: WAR dosyası bulunamadı.
    exit /b 1
)

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

REM WAR dosyasını ve varsa virtualwarlib.zip dosyasını zipleyin
if exist %WAR_DIR%\virtualwarlib.zip (
    echo WAR dosyası ve virtualwarlib.zip dosyası zipleniyor...
    powershell Compress-Archive -Path "%WAR_DIR%\library.war", "%WAR_DIR%\virtualwarlib.zip" -DestinationPath "%PACKAGES_DIR%\%formattedDate%-library-war.zip"
) else (
    echo Sadece WAR dosyası zipleniyor...
    powershell Compress-Archive -Path "%WAR_DIR%\library.war" -DestinationPath "%PACKAGES_DIR%\%formattedDate%-library-war.zip"
)

REM Temp klasörü temizle
rmdir /S /Q %TEMP_JAR_DIR%

REM Eğer herhangi bir hata olursa, script burada durur
IF ERRORLEVEL 1 (
    echo WAR dosyasının ziplenmesi başarısız oldu.
    exit /b 1
)

echo ***** Deployment Dosyası Hazır *****
exit /b 0
