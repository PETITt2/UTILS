# Installation d’un serveur DHCP sous Debian

## Objectif

Ce guide décrit les étapes nécessaires pour installer et configurer un serveur **DHCP** sur une machine Debian.  
L’exemple utilise une **machine virtuelle (VM)** sous **Proxmox**, mais la procédure est la même sur une machine physique.  

L’objectif est que cette machine attribue automatiquement des adresses IP aux clients connectés à son réseau local.

> Ce guide suppose que Debian est déjà installée et fonctionnelle, mais sans configuration réseau spécifique (installation par défaut).

---

## Prérequis

- Une machine sous **Debian** (serveur DHCP).
- Un autre ordinateur configuré pour **obtenir une adresse IP automatiquement (DHCP)**.
- Un **câble Ethernet** reliant le serveur et le client.
- Le **mot de passe root** du serveur Debian.
- Un **accès SSH** est recommandé pour faciliter la configuration.

---

## Configuration de l’adresse IP statique du serveur

### 1. Modifier le fichier de configuration réseau

Ouvrez le fichier suivant :

```bash
sudo nano /etc/network/interfaces
```

Ajoutez la configuration d’une adresse IP statique adaptée à votre environnement :

```bash
auto ens18
iface ens18 inet static
    address 192.168.50.4/24
    gateway 192.168.50.1
```

> Cette configuration définit une IP fixe pour l’interface réseau `ens18`.  
> Vous pouvez adapter le nom de l’interface et les adresses IP selon votre réseau local.

### 2. Redémarrer le service réseau

```bash
sudo systemctl restart networking
```

(Selon certaines versions de Debian)

```bash
sudo systemctl restart network
```

---

## Installation du serveur DHCP (dnsmasq)

Installez **dnsmasq**, un service léger faisant office à la fois de **serveur DHCP** et de **DNS local** :

```bash
sudo apt install dnsmasq -y
```

---

## Configuration de dnsmasq

Éditez le fichier principal de configuration :

```bash
sudo nano /etc/dnsmasq.conf
```

Ajoutez la configuration suivante (à adapter selon votre réseau) :

```bash
# Interface réseau à écouter
interface=ens18
bind-interfaces

# Plage DHCP attribuée aux clients
dhcp-range=192.168.50.10,192.168.50.100,12h

# Passerelle par défaut
dhcp-option=3,192.168.50.1

# Serveurs DNS fournis aux clients
dhcp-option=6,8.8.8.8,8.8.4.4

# Nom de domaine local
domain=lan
```

---

## Redémarrage et activation du service

Exécutez les commandes suivantes :

```bash
sudo systemctl restart dnsmasq     # Redémarre le service pour appliquer les changements
sudo systemctl enable dnsmasq      # Active dnsmasq au démarrage
sudo systemctl status dnsmasq      # Vérifie son état
```

Si le service est **actif (running)**, la configuration est correcte.

---

## Test du serveur DHCP

Branchez un poste client (par exemple, un PC Windows) en **Ethernet** directement au serveur.  
Puis, dans l’invite de commandes du client, exécutez :

```cmd
ipconfig /release
ipconfig /renew
```

Si une adresse IP de la plage configurée (par exemple `192.168.50.10-100`) est attribuée,  
le serveur DHCP fonctionne correctement.

---

## Conclusion

Vous disposez maintenant d’un **serveur DHCP Debian** fonctionnel, capable d’attribuer des adresses IP à vos machines clientes.  
Cette configuration est idéale pour des **petits réseaux locaux** ou des **environnements de test** (VM, lab, etc.).
