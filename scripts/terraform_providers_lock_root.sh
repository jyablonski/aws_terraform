#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_amd64 \
  -platform=darwin_arm64
