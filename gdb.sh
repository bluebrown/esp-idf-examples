#!/usr/bin/env bash
set -Eeuo pipefail

gdb_binary=~/.espressif/tools/xtensa-esp-elf-gdb/14.2_20240403/xtensa-esp-elf-gdb/bin/xtensa-esp32-elf-gdb

exec "$gdb_binary" --command .gdbinit "$@"
