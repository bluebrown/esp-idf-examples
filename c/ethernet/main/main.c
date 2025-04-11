#include "esp_eth.h"
#include "esp_eth_mac.h"
#include "esp_event.h"
#include "esp_log.h"
#include <esp_netif.h>

static const char *TAG = "application";

void app_main(void) {
  ESP_LOGI(TAG, "create default event loop");

  esp_err_t err = esp_event_loop_create_default();
  if (err != ESP_OK) {
    ESP_LOGE(TAG, "esp_event_loop_create_default: %s", esp_err_to_name(err));
    return;
  }

  ESP_LOGI(TAG, "configure netif");

  err = esp_netif_init();
  if (err != ESP_OK) {
    ESP_LOGE(TAG, "esp_netif_init: %s", esp_err_to_name(err));
    return;
  }

  esp_netif_inherent_config_t esp_netif_config =
      ESP_NETIF_INHERENT_DEFAULT_ETH();

  esp_netif_config.if_desc = "ETH";
  esp_netif_config.route_prio = 64;

  esp_netif_config_t netif_config = {
      .base = &esp_netif_config,
      .stack = ESP_NETIF_NETSTACK_DEFAULT_ETH,
  };

  esp_netif_t *netif = esp_netif_new(&netif_config);
  if (netif == NULL) {
    ESP_LOGE(TAG, "esp_netif_new: returned NULL");
    return;
  }

  ESP_LOGI(TAG, "configure mac");

  eth_mac_config_t mac_config = ETH_MAC_DEFAULT_CONFIG();

  esp_eth_mac_t *mac = esp_eth_mac_new_openeth(&mac_config);
  if (mac == NULL) {
    ESP_LOGE(TAG, "esp_eth_mac_new_openeth: returned NULL");
    return;
  }

  ESP_LOGI(TAG, "configure phy");

  eth_phy_config_t phy_config = ETH_PHY_DEFAULT_CONFIG();
  phy_config.autonego_timeout_ms = 100;

  esp_eth_phy_t *phy = esp_eth_phy_new_dp83848(&phy_config);
  if (phy == NULL) {
    ESP_LOGE(TAG, "esp_eth_phy_new_dp83848: returned NULL");
    return;
  }

  ESP_LOGI(TAG, "configure driver");

  esp_eth_config_t config = ETH_DEFAULT_CONFIG(mac, phy);
  esp_eth_handle_t eth_handle = NULL;

  err = esp_eth_driver_install(&config, &eth_handle);
  if (err != ESP_OK) {
    ESP_LOGE(TAG, "esp_eth_driver_install: %s", esp_err_to_name(err));
    return;
  }

  ESP_LOGI(TAG, "attach driver to netif");

  esp_eth_netif_glue_handle_t eth_glue = esp_eth_new_netif_glue(eth_handle);
  if (eth_glue == NULL) {
    ESP_LOGE(TAG, "esp_eth_new_netif_glue: returned NULL");
  }

  err = esp_netif_attach(netif, eth_glue);
  if (err != ESP_OK) {
    ESP_LOGE(TAG, "esp_netif_attach: %s", esp_err_to_name(err));
    return;
  }

  ESP_LOGI(TAG, "start eth");

  err = esp_eth_start(eth_handle);
  if (err != ESP_OK) {
    ESP_LOGE(TAG, "esp_eth_start: %s", esp_err_to_name(err));
    return;
  }
}
