# Ethernet

## Setup

     cd ethernet
     source .envrc
     idf_tools.py install --targets esp32 all
     . ~/.espressif/esp-idf/v5.3.2/export.sh

## Run

    idf.py qemu

The output should look like this:

    I (1897) main_task: Calling app_main()
    I (1897) application: create default event loop
    I (1897) application: configure netif
    I (1907) application: configure mac
    I (1907) application: configure phy
    I (1907) application: configure driver
    I (1937) application: attach driver to netif
    I (1937) esp_eth.netif.netif_glue: 00:00:00:00:00:03
    I (1947) esp_eth.netif.netif_glue: ethernet attached to netif
    I (1947) application: start eth
    I (3067) esp_netif_handlers: ETH ip: 10.0.2.15, mask: 255.255.255.0, gw: 10.0.2.2

## Debug

First run qemu with gdb server.

    id.py qemu --gdb

Then, in another terminal connect to it with gdb. This will use the
[.gdbinit file](./.gdbinit).

    xtensa-esp32-elf-gdb
