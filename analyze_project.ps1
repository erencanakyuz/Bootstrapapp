# Flutter Proje Analiz Script'i
# Tüm gereksiz şeyleri tespit eder

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  FLUTTER PROJE ANALİZİ BAŞLATILIYOR" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Kod Analizi
Write-Host "[1/7] Kod Analizi Yapılıyor..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Kod analizi tamamlandı`n" -ForegroundColor Green
} else {
    Write-Host "⚠ Kod analizinde sorunlar bulundu`n" -ForegroundColor Red
}

# 2. Kullanılmayan Import'ları Düzelt
Write-Host "[2/7] Kullanılmayan Import'lar Kontrol Ediliyor..." -ForegroundColor Yellow
dart fix --dry-run
Write-Host "Düzeltmeleri uygulamak için: dart fix --apply`n" -ForegroundColor Cyan

# 3. Kod Formatı Kontrolü
Write-Host "[3/7] Kod Formatı Kontrol Ediliyor..." -ForegroundColor Yellow
dart format --set-exit-if-changed lib/
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Kod formatı doğru`n" -ForegroundColor Green
} else {
    Write-Host "⚠ Kod formatı düzeltilmeli. Çalıştırın: dart format lib/`n" -ForegroundColor Yellow
}

# 4. Dependency Kontrolü
Write-Host "[4/7] Dependency Durumu Kontrol Ediliyor..." -ForegroundColor Yellow
flutter pub outdated
Write-Host "`n"

# 5. Asset Boyutları
Write-Host "[5/7] Asset Boyutları Hesaplanıyor..." -ForegroundColor Yellow
if (Test-Path "assets") {
    Write-Host "Asset klasör boyutları:" -ForegroundColor Cyan
    Get-ChildItem -Path "assets" -Directory | ForEach-Object {
        $size = (Get-ChildItem -Path $_.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "  $($_.Name): $([math]::Round($size, 2)) MB" -ForegroundColor White
    }
} else {
    Write-Host "⚠ assets klasörü bulunamadı`n" -ForegroundColor Yellow
}
Write-Host "`n"

# 6. Kullanılmayan Dependency Kontrolü (Manuel)
Write-Host "[6/7] Dependency Kullanımı Kontrol Ediliyor..." -ForegroundColor Yellow
Write-Host "pubspec.yaml'daki dependency'ler:" -ForegroundColor Cyan
$dependencies = Get-Content "pubspec.yaml" | Select-String -Pattern "^\s+\w+:" | ForEach-Object { $_.Line.Trim() }
foreach ($dep in $dependencies) {
    $depName = $dep -replace ":\s.*", "" -replace "^\s+", ""
    if ($depName -ne "flutter" -and $depName -notmatch "sdk:") {
        $usage = Select-String -Path "lib\*.dart" -Pattern $depName -Recurse -ErrorAction SilentlyContinue
        if (-not $usage) {
            Write-Host "  ⚠ $depName kullanılmıyor olabilir" -ForegroundColor Yellow
        } else {
            Write-Host "  ✓ $depName kullanılıyor" -ForegroundColor Green
        }
    }
}
Write-Host "`n"

# 7. Build Size Analizi (Opsiyonel)
Write-Host "[7/7] Build Size Analizi (Opsiyonel)..." -ForegroundColor Yellow
$runBuild = Read-Host "Build size analizi yapmak ister misiniz? (y/n)"
if ($runBuild -eq "y" -or $runBuild -eq "Y") {
    Write-Host "Build başlatılıyor... (Bu biraz zaman alabilir)" -ForegroundColor Cyan
    flutter build apk --release --analyze-size
} else {
    Write-Host "Build analizi atlandı`n" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ANALİZ TAMAMLANDI" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Öneriler:" -ForegroundColor Yellow
Write-Host "  1. Kullanılmayan import'ları kaldırmak için: dart fix --apply" -ForegroundColor White
Write-Host "  2. Kod formatını düzeltmek için: dart format lib/" -ForegroundColor White
Write-Host "  3. Detaylı analiz için: ANALIZ_KOMUTLARI.md dosyasına bakın" -ForegroundColor White
Write-Host "`n"

