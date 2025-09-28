# 🌐 Projet Terraform + Ansible : Déploiement d’une Infra Linux/Windows sur Azure

## 📋 Objectif du projet
Ce projet déploie automatiquement **deux machines virtuelles** dans Azure grâce à **Terraform** :
- **VM Linux (Ubuntu)** : héberge un **site web Nginx** simple.
- **VM Windows Server 2019** : utilisée pour les tests **Ansible/WinRM** et l’installation de rôles Windows (ex : Active Directory DS).

La configuration logicielle (installation des paquets, site web, etc.) est ensuite assurée par **Ansible**.

---

## ☁️ Infrastructure créée avec Terraform

### 1️⃣ Composants déployés
| Ressource                  | Détails |
|------------------------------|-------|
| **Resource Group**          | `rg1` |
| **Virtual Network**         | `vnet-demo` (10.0.0.0/16) |
| **Subnet**                  | `subnet-demo` (10.0.1.0/24) |
| **NSG (Security Group)**    | `nsg-demo` avec les règles :
|                             | - SSH (22) pour Linux |
|                             | - HTTP (80) pour le site web |
|                             | - RDP (3389) pour Windows |
|                             | - WinRM (5985) pour Ansible Windows |
| **VM Linux**                | `vm-linux-demo` (Ubuntu 18.04) |
| **VM Windows**              | `vm-windows-demo` (Windows Server 2019) |
| **Public IPs**              | IPs statiques attribuées à chaque VM |
| **Storage Account**         | Pour des tests de stockage Azure (optionnel) |

### 2️⃣ Localisation
Toutes les ressources sont déployé
