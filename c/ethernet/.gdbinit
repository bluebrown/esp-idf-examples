set confirm off
target remote 127.0.0.1:1234
symbol-file ./build/ethernet.elf
set disassemble-next-line auto
set breakpoint pending on
break app_main
tui enable
layout reg
cont

