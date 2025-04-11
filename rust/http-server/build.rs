fn main() {
    embuild::espidf::sysenv::output();
    println!("cargo::rustc-cfg=esp_idf_eth_use_openeth");
}
