# 🌐 Projet Terraform + Ansible – Déploiement d’une Infrastructure Linux + Windows sur Azure

## 🎯 Objectif du projet
Ce projet automatise **la création d’une infrastructure Cloud sur Azure** avec **Terraform**,  
puis configure les machines virtuelles grâce à **Ansible**.  
L’objectif est de démontrer l’Infrastructure as Code (IaC) en déployant :

- ✅ **Une VM Linux (Ubuntu)** : héberge un **site web Nginx** accessible publiquement.
- ✅ **Une VM Windows Server 2019** : utilisée pour des tests **WinRM** et l’installation de rôles Windows (Active Directory Domain Services).

---

## ☁️ Infrastructure déployée avec Terraform

### Ressources principales
| Ressource                     | Détails |
|--------------------------------|----------------------------------------------|
| **Resource Group**             | `rg1` |
| **Virtual Network (VNet)**     | `vnet-demo` – Adresse : `10.0.0.0/16` |
| **Subnet**                     | `subnet-demo` – Adresse : `10.0.1.0/24` |
| **Network Security Group (NSG)**| `nsg-demo` – Règles ouvertes : |
|                                 | • **SSH (22)** : Accès SSH à la VM Linux |
|                                 | • **HTTP (80)** : Accès web Nginx |
|                                 | • **RDP (3389)** : Accès Bureau à distance Windows |
|                                 | • **WinRM (5985)** : Connexion Ansible Windows |
| **VM Linux**                   | `vm-linux-demo` – Ubuntu 18.04 – Taille `Standard_B1s` |
| **VM Windows**                 | `vm-windows-demo` – Windows Server 2019 – Taille `Standard_B2ms` *(plus de RAM pour AD DS)* |
| **Public IPs**                 | IPs statiques pour chaque VM |
| **Storage Account**            | `sstoragedemo1999yasmine` – Stockage Blob/Table/Queue (test) |

Toutes les ressources sont déployées dans la région **Canada Central**.

---

## 🔑 Adresses publiques
| Machine        | Adresse publique | Utilisation |
|----------------|------------------|--------------|
| **Linux (Site Web)** | 🌍 [http://4.206.43.7](http://4.206.43.7) | Site Nginx |
| **Windows (RDP/WinRM)** | 4.206.161.16 | Connexion RDP + Ansible |

---

## ⚡ Déploiement Terraform

### Commandes
Initialiser et déployer toute l’infrastructure Azure :
```bash
terraform init
terraform plan
terraform apply
```
➡️ À la fin du déploiement, Terraform affiche les adresses **IP publiques** à utiliser dans Ansible.

---

## 🤖 Configuration Ansible

### 1️⃣ Inventaire (`inventory.ini`)
Déclare les hôtes Linux et Windows avec les IPs générées par Terraform :
```ini
[linux]
vm_linux ansible_host=4.206.43.7 ansible_user=azureuser ansible_password=Password1234! ansible_connection=ssh

[windows]
vm_windows ansible_host=4.206.161.16
ansible_user=azureuser
ansible_password=Password1234!
ansible_connection=winrm
ansible_winrm_transport=basic
ansible_port=5985
ansible_winrm_server_cert_validation=ignore
```

### 2️⃣ Configuration générale (`ansible.cfg`)
```ini
[defaults]
inventory = ./inventory.ini
remote_user = azureuser
host_key_checking = False
interpreter_python = auto_silent
timeout = 30

[privilege_escalation]
become = True
become_method = sudo
```

---

## 📜 Playbooks Ansible

### 🔹 Linux – `playbooks/linux_web.yml`
Ce playbook configure la VM Linux pour héberger un site web :

- ✅ Mise à jour et mise à niveau des paquets
- ✅ Installation de **Nginx**
- ✅ Création du dossier `/var/www/html`
- ✅ Déploiement d’une page HTML simple depuis un template (`templates/index.html.j2`)
- ✅ Activation et démarrage du service **Nginx**

➡️ **Résultat** : Site accessible publiquement sur [http://4.206.43.7](http://4.206.43.7).

---

### 🔹 Windows – `playbooks/windows_init.yml`
Ce playbook configure la VM Windows :

- ✅ Installation de la **feature AD-Domain-Services** (préparation d’un futur Active Directory)
- ✅ Création d’un **utilisateur local** `opsadmin`
- ✅ Copie d’un fichier `C:\Users\Public\README-ansible.txt`
- ✅ Redémarrage automatique si nécessaire

⚠️ **Note** : Pour installer AD DS, la VM doit être en **Standard_B2ms** (plus de mémoire).

---

## 💻 Commandes Ansible

Tester les connexions :
```bash
ansible linux -m ping
ansible windows -m win_ping
```

Exécuter les playbooks :
```bash
ansible-playbook playbooks/linux_web.yml
ansible-playbook playbooks/windows_init.yml
```

---

## 📂 Structure du projet
```
.
├─ ansible/
│  ├─ ansible.cfg              # Configuration Ansible
│  ├─ inventory.ini             # Inventaire des hôtes Linux/Windows
│  ├─ playbooks/
│  │   ├─ linux_web.yml         # Playbook Nginx
│  │   └─ windows_init.yml      # Playbook Windows
│  └─ templates/
│      └─ index.html.j2         # Template HTML du site web
└─ terraform/
   └─ main.tf                   # Script Terraform (réseau, VMs, NSG, Storage Account…)
```

---

## ⚡ Points clés appris
- **Infrastructure as Code (IaC)** : Terraform automatise la création des ressources Azure.
- **Automatisation** : Ansible configure automatiquement Linux et Windows.
- **Multi-OS** : Gestion simultanée d’une VM Linux (SSH) et Windows (WinRM).
- **Sécurité** : NSG configure uniquement les ports nécessaires (22, 80, 3389, 5985).

---

## 🚀 Résultat final
✅ **VM Linux** : Site web Nginx en ligne → [http://4.206.43.7](http://4.206.43.7)  
✅ **VM Windows** : Connectable en **RDP** et administrable avec Ansible via **WinRM**  
✅ Le tout déployé automatiquement avec **Terraform** et configuré avec **Ansible**.

---

## 🔗 Liens utiles
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Ansible WinRM Documentation](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html)
- [Nginx Documentation](https://nginx.org/en/)

---

> **Auteur** : *Yasmine Yahiaoui*  
> Projet pédagogique – Déploiement Cloud Azure avec **Terraform** et **Ansible**.
