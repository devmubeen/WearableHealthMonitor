terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# IoT Hub Module
module "iot_hub" {
  source              = "./modules/iot"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  iot_hub_name        = var.iot_hub_name
  dps_name            = var.dps_name
  tags                = var.tags
}

# Storage Module
module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  storage_account_name = var.storage_account_name
  tags                = var.tags
}

# Function App Module
module "function_app" {
  source               = "./modules/function"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  function_app_name    = var.function_app_name
  storage_account_name = module.storage.storage_account_name
  storage_account_key  = module.storage.storage_account_primary_key
  app_service_plan_id  = module.storage.app_service_plan_id
  iot_hub_connection   = module.iot_hub.event_hub_connection_string
  synapse_connection   = module.synapse.synapse_connection_string
  tags                 = var.tags
}

# Synapse Module
module "synapse" {
  source                      = "./modules/synapse"
  resource_group_name         = azurerm_resource_group.main.name
  location                    = azurerm_resource_group.main.location
  synapse_workspace_name      = var.synapse_workspace_name
  storage_data_lake_gen2_id   = module.storage.data_lake_gen2_id
  storage_account_name        = module.storage.storage_account_name
  sql_admin_username          = var.sql_admin_username
  sql_admin_password          = var.sql_admin_password
  tags                        = var.tags
}

# Key Vault for Secrets
resource "azurerm_key_vault" "main" {
  name                = "${var.prefix}-kv-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create", "Get", "List", "Update", "Delete", "Purge", "Recover"
    ]

    secret_permissions = [
      "Set", "Get", "List", "Delete", "Purge", "Recover"
    ]
  }

  tags = var.tags
}

# Store secrets in Key Vault
resource "azurerm_key_vault_secret" "iot_hub_connection" {
  name         = "iot-hub-connection-string"
  value        = module.iot_hub.iot_hub_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "dps_connection" {
  name         = "dps-connection-string"
  value        = module.iot_hub.dps_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

data "azurerm_client_config" "current" {}