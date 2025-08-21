terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}


resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${lower(var.web_app_name)}-sqlsvr"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_db_usr
  administrator_login_password = var.sql_db_pass
}


resource "azurerm_mssql_database" "sqldatabase" {
  name                             = "${var.web_app_name}-sqldb"
  server_id                        = azurerm_mssql_server.sqlserver.id
  auto_pause_delay_in_minutes      = 60
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  sku_name                         = "GP_S_Gen5_1"
  storage_account_type             = "Local"
  min_capacity                     = 0.5
}


# Enables the "Allow Access to Azure services" box
resource "azurerm_mssql_firewall_rule" "sql_fw" {
  name                = "allow access from Azure services to web app"
  server_id           = azurerm_mssql_server.sqlserver.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}


resource "azurerm_service_plan" "sp" {
  name                = "${var.web_app_name}-ServicePlan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}



resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.sp.id

  https_only = true

  logs {
    http_logs {
      file_system {
        retention_in_days = 10
        retention_in_mb = 35
      }
    }
  }

  connection_string {
    name = "connectionString1"
    type = "SQLServer"
    value = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:${azurerm_mssql_server.sqlserver.name}.database.windows.net,1433;Database=${azurerm_mssql_database.sqldatabase.name};Uid=${var.sql_db_usr};Pwd=${var.sql_db_pass};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
  }

  site_config {
    application_stack {
      python_version = "3.8"
    }
    ftps_state = "FtpsOnly"
    vnet_route_all_enabled = true
  }

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = true
    STORAGE_ACCOUNT_URL = "https://${lower(var.web_app_name)}.blob.core.windows.net"
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_source_control_token" "gh_token" {
  type  = "GitHub"
  token = var.github_auth_token
}


resource "azurerm_app_service_source_control" "scm" {
  app_id   = azurerm_linux_web_app.app.id
  repo_url = var.github_url
  branch   = "main"

  github_action_configuration {
    code_configuration {
      runtime_stack = "python"
      runtime_version = "3.8"
    }
    generate_workflow_file = true
  }
}


resource "azurerm_storage_account" "strg_acc" {
  name                            = "${lower(var.web_app_name)}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  allow_nested_items_to_be_public = false
}


resource "azurerm_storage_container" "strg_cont" {
  name                  = "api-logs"
  storage_account_name  = azurerm_storage_account.strg_acc.name
}


resource "azurerm_role_assignment" "app_to_storage" {
  scope                = azurerm_storage_account.strg_acc.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}