gh_token=$1

## Prepare Github secret AZURE_SQL_CONNECTION_STRING.
## Execute this when want to parametrize the db username, password, server name etc.
## Prerequisite:
## Install gh (Github CLI)
#export GH_TOKEN=${gh_token}
#gh secret set AZURE_SQL_CONNECTION_STRING --body "Driver={ODBC Driver 18 for SQL Server};Server=tcp:<parameter>.database.windows.net,1433;Database=<parameter>;Uid=<parameter>;Pwd=<parameter>;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;" -R oritzadok/restaurant-assignment



# Terraform may fail setting the Github source control token in the web app,
# in case there's already existing one cached in Azure app service.
# ("Error: A resource with the ID "/providers/Microsoft.Web/sourceControls/GitHub" already
# exists - to be managed via Terraform this resource needs to be imported into the State")
# This command will clean up existing token.
az webapp deployment source update-token



cd terraform

echo "github_auth_token = \"${gh_token}\"" >> terraform.tfvars

terraform init
terraform apply -auto-approve
