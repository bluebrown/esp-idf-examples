use esp_idf_svc::{eth, eventloop, hal, http, io::Write, netif};
use std::thread;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    esp_idf_svc::sys::link_patches();
    esp_idf_svc::log::EspLogger::initialize_default();

    let eloop = eventloop::EspSystemEventLoop::take()?;
    let peri = hal::peripherals::Peripherals::take()?;

    log::info!("init eth");
    let netif = netif::EspNetif::new(netif::NetifStack::Eth)?;
    let driver = eth::EthDriver::new_openeth(peri.mac, eloop)?;
    let mut eth = eth::EspEth::wrap_all(driver, netif)?;
    eth.start()?;

    log::info!("init server");
    let config = http::server::Configuration::default();
    let mut server = http::server::EspHttpServer::new(&config)?;

    server.fn_handler("/", http::Method::Get, |req| {
        log::info!("Received GET request");
        let mut rsp = req.into_ok_response()?;
        rsp.write_all(b"Hello, world!")?;
        rsp.flush()
    })?;

    thread::park();
    Ok(())
}
