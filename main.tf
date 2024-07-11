resource "azurerm_virtual_network" "example_vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "rg-ML-AI"  # Reemplaza con el nombre de tu grupo de recursos
}

resource "azurerm_subnet" "example_subnet" {
  name                 = "example-subnet"
  resource_group_name  = "rg-ML-AI"  # Reemplaza con el nombre de tu grupo de recursos
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.CognitiveServices"]
}

resource "azurerm_cognitive_account" "example_OpenAI" {
  name                = "example_OpenAI"
  resource_group_name = "rg-ML-AI"
  location            = "East US"
  sku_name            = "S0"  # SKU del servicio de Cognitive Services
  kind                = "OpenAI"  # Tipo de servicio de Cognitive Services

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_subnet.example_subnet]  # Asegura la creación del recurso de Subnet antes de aplicar las reglas de red

  network_acls {
    default_action = "Deny"

    virtual_network_rules {
      subnet_id = azurerm_subnet.example_subnet.id
    }
  }

  custom_subdomain_name = "example-subdomain"  
  
}

resource "azurerm_search_service" "example_search" {
  name                = "example-aisearch"
  resource_group_name = "rg-ML-AI"
  location            = "East US"
  sku                 = "basic"
  partition_count     = 1
  replica_count       = 1

  # hosting_mode {
  #   hosting_mode = "default"
  # }

  # network_rule_set {
  #   default_action = "Deny"
  # }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_subnet.example_subnet]  # Asegura la creación del recurso de Subnet antes de aplicar las reglas de red

}

# resource "azurerm_cognitive_services_account_network_rule" "example_network_rule" {
#   cognitive_services_account_id = azurerm_cognitive_account.example_openai.id
#   subnet_id                     = azurerm_subnet.example_subnet.id
# }
