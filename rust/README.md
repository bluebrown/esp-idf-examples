# Rust Examples

Generate a new project. Make sure to use esp-idf 5.3.

```bash
cargo generate esp-rs/esp-idf-template cargo
```

Change the runner in .cargo/config.toml.

```toml
[build]
runner = "../runner.sh"
```

Add the .envrc.

```bash
export IDF_TOOLS_PATH="$PWD/.embuild/espressif/"
source ~/export-esp.sh
PATH_add .embuild/espressif/esp-idf/v5.3.2/components/nvs_flash/nvs_partition_generator/
PATH_add .embuild/espressif/tools/qemu-xtensa/esp_develop_9.0.0_20240606/qemu/bin/
pyenv=.embuild/espressif/python_env/idf5.3_py3.13_env/
[ -d "$pyenv" ] && source "$pyenv/bin/activate"
```
