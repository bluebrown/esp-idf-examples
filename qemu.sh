#!/usr/bin/env bash
set -Eeuo pipefail

qemu_binary=~/.espressif/tools/qemu-xtensa/esp_develop_9.0.0_20240606/qemu/bin/qemu-system-xtensa

prefix=
psram=4M
strap_mode=0x12
flash_image=build/merged-binary.bin
efuse_file=build/qemu_efuse.bin
nowatchdog=true
debug=false

while getopts "dp:s:f:e:m:w" opt; do
	case $opt in
	d) debug=true ;;
	p) prefix=$OPTARG ;;
	s)
		if [ "$OPTARG" = "flash" ]; then
			strap_mode="0x12"
		elif [ "$OPTARG" = "uart" ]; then
			strap_mode="0x0f"
		else
			echo "Invalid strap mode: $OPTARG" >&2
			echo "Valid options are 'flash' or 'uart'" >&2
			exit 1
		fi
		;;
	f) flash_image=$OPTARG ;;
	e) efuse_file=$OPTARG ;;
	m) psram=$OPTARG ;;
	w) nowatchdog=false ;;
	*)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

flash_image="${prefix}${flash_image}"
efuse_file="${prefix}${efuse_file}"

if [ ! -f "$efuse_file" ]; then
	echo "Creating efuse file $efuse_file"
	cat <<-EOF | xxd -r -p >"$efuse_file"
		000000000000000000000000008000000000000000001000000000000000
		000000000000000000000000000000000000000000000000000000000000
		000000000000000000000000000000000000000000000000000000000000
		000000000000000000000000000000000000000000000000000000000000
		00000000
	EOF

else
	echo "Using existing efuse file $efuse_file"
fi

qemu_args=(
	-nographic -machine "esp32" -m "$psram"
	-global "driver=esp32.gpio,property=strap_mode,value=$strap_mode"
	-global "driver=timer.esp32.timg,property=wdt_disable,value=$nowatchdog"
	-global "driver=nvram.esp32.efuse,property=drive,value=efuse"
	-drive "file=$efuse_file,if=none,format=raw,id=efuse"
)

if [ "$strap_mode" = 0x12 ]; then
	qemu_args+=(
		-monitor "pty"
		-drive "file=$flash_image,if=mtd,format=raw"
		-nic "user,model=open_eth"
	)
else
	qemu_args+=(-serial pty)
fi

if [ "$debug" = true ]; then
	qemu_args+=(-s -S)
fi

exec "$qemu_binary" "${qemu_args[@]}" "$@"
