@echo off
echo ========================================
echo Android WiFi Baglanti Araci
echo ========================================
echo.

echo Telefon IP adresini girin (ornek: 192.168.1.100):
set /p PHONE_IP="IP: "

echo.
echo Port numarasini girin (ornek: 5555 veya wireless debugging portu):
set /p PORT="Port: "

echo.
echo ========================================
echo Baglanti yapiliyor...
echo ========================================
echo.

adb connect %PHONE_IP%:%PORT%

echo.
echo Bagli cihazlar kontrol ediliyor...
adb devices

echo.
echo Flutter cihazlar kontrol ediliyor...
flutter devices

echo.
echo ========================================
echo Baglanti tamamlandi!
echo.
echo Uygulamayi calistirmak icin:
echo   flutter run
echo.
echo Baglantiyi kesmek icin:
echo   adb disconnect %PHONE_IP%:%PORT%
echo ========================================
pause

