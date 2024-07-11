# Recurso para la creación de la red virtual
resource "azurerm_virtual_network" "example_vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "rg-ML-AI"
}

# Recurso para la creación del subnet PRIVAT AI SUBNET
resource "azurerm_subnet" "private_ai_subnet" {
  name                 = "privat-ai-subnet"
  resource_group_name  = "rg-ML-AI"
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.2.0/24"]  # Ajusta según tu necesidad

  # Aquí podrías definir reglas de NSG específicas si es necesario
}

# Recurso para la creación del subnet PRIVATE ENDPOINT SUBNET
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "private-endpoint-subnet"
  resource_group_name  = "rg-ML-AI"
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.3.0/24"]  # Ajusta según tu necesidad

  # Aquí podrías definir reglas de NSG específicas si es necesario
}


# Recurso para la creación del servicio de Cognitive Services
resource "azurerm_cognitive_account" "sura_openai3" {
  name                = "sura-openai3"
  resource_group_name = "rg-ML-AI"
  location            = "East US"
  sku_name            = "S0"  # SKU del servicio de Cognitive Services
  kind                = "OpenAI"  # Tipo de servicio de Cognitive Services

  identity {
    type = "SystemAssigned"
  }

  network_acls {
    default_action = "Deny"
  }

  custom_subdomain_name = "opeain-subdomain3"

  depends_on = [azurerm_subnet.private_ai_subnet]  # Asegura la creación del recurso de Subnet antes de aplicar las reglas de red

}

# Recurso para la creación del Private Endpoint para Cognitive Services
resource "azurerm_private_endpoint" "example_endpoint" {
  name                = "example-endpoint"
  location            = "East US"
  resource_group_name = "rg-ML-AI"
  subnet_id           = azurerm_subnet.private_endpoint_subnet.id

  private_service_connection {
    name                           = azurerm_cognitive_account.sura_openai3.name
    private_connection_resource_id = azurerm_cognitive_account.sura_openai3.id
    is_manual_connection           = false  # Automáticamente conectar al recurso
    subresource_names              = ["account"]
  }

  tags = {
    environment = "production"
  }
}

# Recurso para la creación del servicio de búsqueda de Azure
# resource "azurerm_search_service" "example_search" {
#   name                = "example-aisearch"
#   resource_group_name = "rg-ML-AI"
#   location            = "East US"
#   sku                 = "basic"
#   partition_count     = 1
#   replica_count       = 1

#   identity {
#     type = "SystemAssigned"
#   }

#   depends_on = [azurerm_subnet.private_ai_subnet]  # Asegura la creación del recurso de Subnet antes de aplicar las reglas de red
# }

# # Recurso para la creación del Private Endpoint para el servicio de búsqueda de Azure
# resource "azurerm_private_endpoint" "search_endpoint" {
#   name                = "search-endpoint"
#   location            = "East US"
#   resource_group_name = "rg-ML-AI"
#   subnet_id           = azurerm_subnet.private_endpoint_subnet.id

#   private_service_connection {
#     name                           = "search-service-connection"
#     private_connection_resource_id = azurerm_search_service.example_search.id
#     is_manual_connection           = false  # Automáticamente conectar al recurso
#   }

#   tags = {
#     environment = "production"
#   }
# }