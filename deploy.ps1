# PhotoPoet Sync & Deploy Script
# This script builds the web app, pushes changes to GitHub, and deploys to Firebase.

Write-Host "--- Starting PhotoPoet Sync & Deploy ---" -ForegroundColor Cyan

# 1. Build the Web App
Write-Host "`n[1/3] Building Flutter Web..." -ForegroundColor Yellow
flutter build web
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Aborting." -ForegroundColor Red
    exit
}

# 1.5 Zip and Copy Release APK to Web Folder
Write-Host "`n[1.5/3] Zipping APK for Web Hosting..." -ForegroundColor Yellow
$apkSource = "build/app/outputs/flutter-apk/app-release.apk"
$zipDest = "build/web/photopoet_android.zip"
if (Test-Path $apkSource) {
    Compress-Archive -Path $apkSource -DestinationPath $zipDest -Force
    Write-Host "APK zipped and ready for download." -ForegroundColor Green
} else {
    Write-Host "Warning: Release APK not found at $apkSource. Skipping versioning." -ForegroundColor Gray
}

# 2. Update GitHub
Write-Host "`n[2/3] Updating GitHub..." -ForegroundColor Yellow
$msg = Read-Host "Enter commit message (or press Enter for 'Auto-update')"
if ([string]::IsNullOrWhiteSpace($msg)) { $msg = "Auto-update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }

git add .
git commit -m "$msg"
git push
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub push failed! Check your connection or conflicts." -ForegroundColor Red
    exit
}

# 3. Deploy to Firebase
Write-Host "`n[3/3] Deploying to Firebase..." -ForegroundColor Yellow
firebase deploy
if ($LASTEXITCODE -ne 0) {
    Write-Host "Firebase deployment failed!" -ForegroundColor Red
    exit
}

Write-Host "`n--- Sync & Deploy Complete! ---" -ForegroundColor Green
