# declare azurerm provider  qui Permet à Terraform de communiquer avec Azure. 
provider "azurerm" {
  features {} //obligatoire meme vide Il sert à activer certaines fonctionnalités avancées du provider si nécessaire. 
  subscription_id = "da54e07e-d4bb-4a6c-8e45-15fa2375a9c8"  # si tu veux forcer un abonnement précis. Sinon Terraform prend l’abonnement par défaut de az login. dans mon caas j ai connecter mon azure 
}
  // create a ressource group   une boîte d’organisation.
resource "azurerm_resource_group" "rg" { //Crée un groupe de ressources dans Azure. nom local RG
  name = "rg1" //  NOM DU GROUP 
  location ="westeurope" // region ou seront cree les resources 
}
# -----------------------------
# 2 Virtual Network (VNet) Réseau virtuel privé dans Azure
# -----------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-demo"
  location            = azurerm_resource_group.rg.location  //On utilise la même région que le Resource Group.
  resource_group_name = azurerm_resource_group.rg.name //Associe le VNet au Resource Group existant (rg1).
  address_space       = ["10.0.0.0/16"] //Définit la plage d’adresses IP privées que le reseaux pourra utiliser , /16 ici permet d’avoir 65 536 adresses IP dans ce réseau
}
# -----------------------------
# 3 Subnet Sous-réseau
# -----------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-demo"
  resource_group_name  = azurerm_resource_group.rg.name //Le subnet appartient au Resource Group créé précédemment (rg1).
  virtual_network_name = azurerm_virtual_network.vnet.name //Le subnet est attaché au VNet existant (vnet-demo).Chaque subnet doit appartenir à un seul VNet.
  address_prefixes     = ["10.0.1.0/24"]
}
#4 Network Security Group (NSG) utiliser pour Sécuriser ton réseau  selon les regles ...
# -----------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
// pour linux  regle ssh
  security_rule { //Définit une règle de sécurité réseau à appliquer au NSG.
    name                       = "AllowSSH"
    priority                   = 1001  //Ordre d’évaluation de la règle (plus petit = plus prioritaire)
    direction                  = "Inbound" //S’applique aux flux entrants
    access                     = "Allow"
    protocol                   = "Tcp" //Protocole autorisé (ici TCP pour SSH)
    source_port_range          = "*"
    destination_port_range     = "22"   //ici, seule la connexion SSH (port 22) est autorisée.
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  //pour windows regle RDP 
  // Règle RDP pour Windows
  security_rule {
    name                       = "AllowRDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389" // port RDP
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 5 Network Interface pour VM --Chaque VM a besoin d’une interface réseau pour communiquer dans le VNet.Network Interface Card).
# -----------------------------
resource "azurerm_public_ip" "pip_linux" {
  name                = "pip-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard" 
  allocation_method   = "Static"   # ou "Static" si tu veux une IP fixe
}


//nic linux 
resource "azurerm_network_interface" "nic_linux" { //On crée une interface réseau (NIC) pour une VM.
  name                = "nic-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  

  ip_configuration {
    name                          = "ipconfig1"  //nom de la configuration IP (obligatoire).
    subnet_id                     = azurerm_subnet.subnet.id //on rattache la NIC au sous-réseau qu’on a créé avant (subnet-demo).
    private_ip_address_allocation = "Dynamic" //l’adresse IP privée sera attribuée automatiquement par Azure (DHCP).
    public_ip_address_id          = azurerm_public_ip.pip_linux.id  
  }
}
// Associer NSG à la NIC Linux
resource "azurerm_network_interface_security_group_association" "linux_nic_nsg" {
  network_interface_id          = azurerm_network_interface.nic_linux.id
  network_security_group_id     = azurerm_network_security_group.nsg.id
}


//Sans elle, la VM ne peut pas se connecter au réseau (comme un PC sans carte réseau).
#6 VM Linux --machine virtuelle Ubuntu déployée dans Azure.
# -----------------------------
resource "azurerm_linux_virtual_machine" "vm_linux" {
  name                = "vm-linux-demo"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" //Taille de la VM = type de machine (CPU/RAM).
  admin_username      = "azureuser" //Identifiants d’accès à la VM.
  admin_password      = "Password1234!" 
  disable_password_authentication = false //connexion avec mot de passe pas cle ssh
  
  network_interface_ids = [azurerm_network_interface.nic_linux.id] //connecte la VM à la NIC déjà créée (nic-linux).

  os_disk {//Définition du disque système de la VM
    caching              = "ReadWrite"//optimisations lecture/écriture.
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"//éditeur officiel d’Ubuntu.
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"//version
    version   = "latest"//prend la dernière mise à jour
  }
}//note: on doit toujours inclure au minimum :

//RG + VNet/Subnet + NIC + VM.
//Ces 4 ressources sont indispensables (plus la clé SSH ou mot de passe pour l’accès).
# 7 VM Windows
#ip public 
resource "azurerm_public_ip" "pip_windows" {
  name                = "pip-windows"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard" 
  allocation_method   = "Static"   # ou "Static" si tu veux une IP fixe
}

# -----------------------------
resource "azurerm_network_interface" "nic_windows" {
  name                = "nic-windows"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
   

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_windows.id 
  }
}
// Associer NSG à la NIC Windows
resource "azurerm_network_interface_security_group_association" "windows_nic_nsg" {
  network_interface_id          = azurerm_network_interface.nic_windows.id
  network_security_group_id     = azurerm_network_security_group.nsg.id
}
resource "azurerm_windows_virtual_machine" "vm_windows" {
  name                = "vm-windows-demo"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Password1234!"
  network_interface_ids = [azurerm_network_interface.nic_windows.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
# 8 Storage Account sert a stocker des blobs(image video fichier ) des tables des queues message entre application 
# -----------------------------
resource "azurerm_storage_account" "storage_demo" {
  name                     = "storagedemo12345yasmine" # Doit être unique
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

//IaC = traiter ton infrastructure comme du code. On écrit “la recette” et le cloud exécute cette recette pour créer les ressources exactement comme tu l’as défini.//
//Avec IaC : tu écris un fichier Terraform avec tout ça, tu l’exécutes, et Azure crée toutes les ressources automatiquement.
//IaC = écrire la définition de ton infrastructure dans un fichier (code), au lieu de créer les ressources manuellement dans le portail Azure.
//💡 Analogie :

//Terraform écrit la “recette” pour Azure.

//Azure suit la recette et crée tout pour toi dans le cloud.

//Tu n’as jamais besoin d’installer Ubuntu/Windows sur ton PC pour faire ces VM.