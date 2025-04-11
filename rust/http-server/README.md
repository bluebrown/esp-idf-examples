# Http Server

## Setup

First build the project once to get all the esp-idf dependencies.
re-source the `.envrc` file to set up the environment variables, after
the first build, because it will create the python envronment.

```bash
source .envrc
cargo build
./.embuild/espressif/esp-idf/v5.3.2/tools/idf_tools.py \
    --targets esp32 qemu-xtensa
```

After the initial setup. The project can be build/run.

```bash
cargo run -- <extra-qemu-args>
```

The output should look like below.

```bash
I (2213) esp_idf_svc::http::server: Started Httpd server with config Configuration ... 
I (2223) esp_idf_svc::http::server: Registered Httpd server handler Get for URI "/"
I (3183) esp_netif_handlers: eth ip: 10.0.2.15, mask: 255.255.255.0, gw: 10.0.2.2
I (9873) firmware: Received GET request
```
