# terraform.tfvars.example
# Copy this file to terraform.tfvars and update with your values

# General settings
prefix               = "health"
environment          = "prod"
location             = "East US"
resource_group_name  = "rg-wearable-health-prod"

# IMPORTANT: Azure resource names must be globally unique
# Add random numbers or your initials to make them unique
iot_hub_name         = "hub-wearable-health-UNIQUE123"
dps_name             = "dps-wearable-health-UNIQUE123"
storage_account_name = "sawearablehealth123"  # lowercase, no hyphens, max 24 chars
function_app_name    = "func-health-proc-UNIQUE123"
synapse_workspace_name = "syn-health-UNIQUE123"

# SQL Admin credentials - use strong passwords
sql_admin_username = "healthadmin"
sql_admin_password = "YourStrongP@ssw0rd123!"  # Change this!

# Tags
tags = {
  Project     = "WearableHealthMonitor"
  Environment = "Production"
  ManagedBy   = "Terraform"
  Owner       = "YourName"
}