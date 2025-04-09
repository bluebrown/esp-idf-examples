# ESP-IDF QEMU Examples

This repository contains example projects using the esp-idf framework
and qemu.

To run an example project, follow these steps.

    bash build.sh ethernet/
    bash qemu.sh -p ethernet/

To run the debug server.

    bash build.sh ethernet/
    bash qemu.sh -p ethernet/ -d

Then in another terminal, run the client.

    bash gdb.sh --cd ethernet/
