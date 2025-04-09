set confirm off
target remote 127.0.0.1:3333
symbol-file ./build/main.elf
set disassemble-next-line auto
set breakpoint pending on
break app_main
tui enable
layout reg
cont

