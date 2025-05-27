# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${var.function_app_name}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "Node.JS"

  tags = var.tags
}

# Function App
resource "azurerm_linux_function_app" "main" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key
  service_plan_id            = var.app_service_plan_id

  site_config {
    application_stack {
      node_version = "18"
    }
    
    cors {
      allowed_origins = ["*"]
    }

    application_insights_key               = azurerm_application_insights.main.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.main.connection_string
  }

  app_settings = {
    # Runtime settings
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~18"
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
    
    # Storage settings
    "AzureWebJobsStorage"           = var.storage_account_connection_string
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = var.storage_account_connection_string
    "WEBSITE_CONTENTSHARE"          = var.function_app_name
    
    # IoT Hub connection
    "IoTHubEventHubConnectionString" = var.iot_hub_connection
    "IoTHubEventHubName"            = "messages/events"
    "IoTHubConsumerGroup"           = "function-consumer-group"
    
    # Synapse connection
    "SynapseConnectionString"        = var.synapse_connection
    
    # Application Insights
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    
    # Additional settings
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}