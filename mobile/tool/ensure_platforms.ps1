# Regenerates Flutter iOS/Android glue if platforms look broken (requires Flutter on PATH).
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "Flutter is not on PATH. Install Flutter, then re-run this script or run: flutter pub get"
  exit 1
}
flutter pub get
flutter create . --project-name ciao_delivery --platforms=android,ios
Write-Host "Done. Open Xcode with ios/Runner.xcworkspace after flutter has run once (pods + Generated.xcconfig)."
