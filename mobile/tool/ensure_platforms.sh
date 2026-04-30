#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not on PATH. Install Flutter, then re-run or: flutter pub get" >&2
  exit 1
fi
flutter pub get
flutter create . --project-name ciao_delivery --platforms=android,ios
echo "Done."
