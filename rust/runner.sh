#!/usr/bin/env bash
set -Eeuo pipefail

elf_file="$1"
rust_target=$(dirname "$elf_file")
shift

flash_size=2MB

esptool.py --chip esp32 elf2image --flash_size $flash_size \
	--output target/factory.bin \
	"$elf_file"

partitions=(
	0x1000 "$rust_target/bootloader.bin"
	0x8000 "$rust_target/partition-table.bin"
	0x10000 target/factory.bin
)

if [ -f data/nvs.csv ]; then
	nvs_partition_gen.py generate data/nvs.csv target/nvs.bin 0x6000
	partitions+=(0x9000 target/nvs.bin)
fi

esptool.py --chip esp32 merge_bin "${partitions[@]}" \
	--flash_size $flash_size --fill-flash-size $flash_size \
	--output target/qemu_flash.bin

cat <<-EOF | xxd -r -p >target/qemu_efuse.bin
	000000000000000000000000008000000000000000001000000000000000
	000000000000000000000000000000000000000000000000000000000000
	000000000000000000000000000000000000000000000000000000000000
	000000000000000000000000000000000000000000000000000000000000
	00000000
EOF

if [[ "${ESP_UART_MODE:-}" == "1" ]]; then
	pty=serial
	mode=0x0f
else
	pty=monitor
	mode=0x12
fi

qemu-system-xtensa -nographic -machine esp32 -m 4M \
	-global driver=timer.esp32.timg,property=wdt_disable,value=true \
	-global driver=nvram.esp32.efuse,property=drive,value=efuse \
	-drive file=target/qemu_efuse.bin,if=none,format=raw,id=efuse \
	-global driver=esp32.gpio,property=strap_mode,value=$mode \
	-drive file=target/qemu_flash.bin,if=mtd,format=raw \
	-nic user,model=open_eth,id=lo0,hostfwd=tcp:127.0.0.1:8080-:80 \
	-$pty pty \
	"$@"
