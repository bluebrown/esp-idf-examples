# Serial Communication

Star the app in qemu

```bash
cargo run -- -serial pty
```

Then in another terminal watch the serial output.

```bash
screen /dev/pts/3
```
