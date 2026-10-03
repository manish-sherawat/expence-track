#!/usr/bin/env bash
set -euo pipefail

echo "Running zero-Material and zero-Cupertino check..."
dart run tool/check_no_material.dart
