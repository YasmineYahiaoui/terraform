# declare azurerm provider  qui Permet à Terraform de communiquer avec Azure. 
provider "azurerm" {
  features {} //obligatoire meme vide Il sert à activer certaines fonctionnalités avancées du provider si nécessaire. 
  subscription_id = "da54e07e-d4bb-4a6c-8e45-15fa2375a9c8"  # si tu veux forcer un abonnement précis. Sinon Terraform prend l’abonnement par défaut de az login. dans mon caas j ai connecter mon azure 
}

  //

  // create a ressource group 
  
resource "azurerm_resource_group" "rg" { //Crée un groupe de ressources dans Azure. nom RG
  name = "rg1" //  NOM DU GROUP 
  location ="westeurope" // region ou seront cree les resources 

}