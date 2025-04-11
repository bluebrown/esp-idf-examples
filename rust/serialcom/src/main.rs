use esp_idf_svc::hal;
use esp_idf_svc::io::Write;
use std::time;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    esp_idf_svc::sys::link_patches();
    esp_idf_svc::log::EspLogger::initialize_default();

    log::info!("init uart0");

    let peri = hal::peripherals::Peripherals::take()?;
    let config = hal::uart::config::Config::default();

    let mut uart = hal::uart::UartDriver::new(
        peri.uart0,
        peri.pins.gpio1,
        peri.pins.gpio3,
        Option::<hal::gpio::AnyIOPin>::None,
        Option::<hal::gpio::AnyIOPin>::None,
        &config,
    )?;

    loop {
        let epoch = time::SystemTime::now().duration_since(time::UNIX_EPOCH)?;
        let string = format!("epoch: {:?}", epoch.as_secs());
        write!(uart, "{}\n\r", string)?;
        std::thread::sleep(time::Duration::from_secs(1));
    }
}
