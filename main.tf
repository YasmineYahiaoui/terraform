# declare azurerm provider
provider "azurerm" {
  features {}
  subscription_id = "da54e07e-d4bb-4a6c-8e45-15fa2375a9c8"  # PAS d'espace avant/après
}

  //

  // create a ressource group 
  
resource "azurerm_resource_group" "rg" {
  name = "rg1"
  location ="westeurope"

}