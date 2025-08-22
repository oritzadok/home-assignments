variable "resource_group_location" {
  default = "uksouth"
}

variable "resource_group_name" {
  default = "restaurantAppResourceGroup"
}

variable "web_app_name" {
  default = "restaurantApp123"
}

variable "github_url" {
  default = "https://github.com/oritzadok/restaurant-assignment.git"
}

variable "github_auth_token" {}


# Make sure the values correspond to what appear in the Github
# repository connection string secret (Since I predefined that secret)
variable "sql_db_usr" {
  default = "azureuser"
}

variable "sql_db_pass" {
  default = "hungry123!"
}
