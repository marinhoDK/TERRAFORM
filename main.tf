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

# Recurso para la creación del subnet FUNCTION SUBNET
resource "azurerm_subnet" "function_subnet" {
  name                 = "function-subnet"
  resource_group_name  = "rg-ML-AI"
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.4.0/24"]  # Ajusta según tu necesidad
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
  subnet_id           = azurerm_subnet.privat-ai-subnet.id

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
resource "azurerm_search_service" "example_search" {
  name                = "example-aisearch"
  resource_group_name = "rg-ML-AI"
  location            = "East US"
  sku                 = "basic"
  partition_count     = 1
  replica_count       = 1

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_subnet.private_ai_subnet]  # Asegura la creación del recurso de Subnet antes de aplicar las reglas de red
}

# Recurso para la creación del Private Endpoint para Azure Search
resource "azurerm_private_endpoint" "search_endpoint" {
  name                = "search-endpoint"
  location            = "East US"
  resource_group_name = "rg-ML-AI"
  subnet_id           = azurerm_subnet.privat-ai-subnet.id

  private_service_connection {
    name                           = azurerm_search_service.example_search.name
    private_connection_resource_id = azurerm_search_service.example_search.id
    is_manual_connection           = false  # Automáticamente conectar al recurso
    subresource_names              = ["searchService"]
  }

  tags = {
    environment = "production"
  }
}

# # Recurso para la creación del Azure Function App
# resource "azurerm_function_app" "example_function" {
#   name                       = "example-function"
#   location                   = "East US"
#   resource_group_name        = "rg-ML-AI"
#   app_service_plan_id        = azurerm_app_service_plan.example_plan.id
#   storage_account_name       = azurerm_storage_account.example_sa.name
#   storage_account_access_key = azurerm_storage_account.example_sa.primary_access_key
#   os_type                    = "linux"
#   version                    = "~3"
#   app_settings = {
#     "FUNCTIONS_WORKER_RUNTIME" = "python"
#   }
# }
