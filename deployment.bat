@echo off
REM JAR dosyalarını sileceğiniz klasörün yolu
SET JAR_DIR=C:\Users\EGEMEN\CODING\Library\lib

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

echo Islem basariyla tamamlandi.
exit
