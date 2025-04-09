#!/usr/bin/env bash
set -Eeuo pipefail
cd "$1"
idf.py merge-bin --fill-flash-size 2MB
