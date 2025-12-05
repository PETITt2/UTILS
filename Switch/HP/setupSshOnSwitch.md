# Configuration SSH sur HP 3600 Series Switch (JG304B / Comware v5)

Ce guide explique comment activer et configurer SSH sur un switch HP 3600 (Comware v5), créer un compte administrateur complet et se connecter via SSH depuis un PC.

---

## 1. Pré-requis

- Câble console (RS232/USB) ou accès réseau direct.
- Terminal type PuTTY ou Tera Term pour la console.
- Adresse IP du PC configurée sur le même sous-réseau que le switch.

---

## 2. Accéder au switch via console

1. Connectez le câble console entre le PC et le switch.
2. Configurez le terminal :

Baud rate : 9600  
Data bits : 8  
Parity    : None  
Stop bits : 1  
Flow ctrl : None  

3. Allumez le switch et connectez-vous.  
   - Le prompt initial devrait être `<HPE>`.

---

## 3. Passer en mode système (mode administrateur complet)

```
system-view
```

- Le prompt change alors pour `[HPE]`.
- Si la commande échoue, cela signifie que le compte utilisé n'a pas les privilèges admin. Dans ce cas, il faudra créer ou réinitialiser un compte admin.

---

## 4. Créer ou configurer le compte admin

```
local-user admin
password simple MHSDhcd53
service-type ssh
authorization-attribute level 3
quit
```

- `password simple MHSDhcd53` : définit le mot de passe (éviter caractères spéciaux `$*` pour compatibilité).  
- `service-type ssh` : permet la connexion SSH.  
- `authorization-attribute level 3` : attribue un niveau administrateur complet.

Vérification :

```
display local-user
```

- Vous devriez voir :

```
Authorization attributes:
  User Privilege: 3
```

---

## 5. Configurer l’IP du switch (VLAN1)

```
interface Vlan-interface 1
ip address 192.168.50.10 255.255.255.0
quit
```

- Adaptez l’IP et le masque à votre réseau local.
- Vérifiez :

```
display ip interface brief
```

---

## 6. Activer le serveur SSH

```
ssh server enable
undo ssh server compatible-ssh1x
```

- Cela active SSHv2 et désactive SSHv1 (obsolète).

---

## 7. Configurer les lignes VTY pour SSH uniquement

```
user-interface vty 0 15
protocol inbound ssh
authentication-mode scheme
quit
```

- `scheme` utilise le compte local (`admin`).

---

## 8. Sauvegarder la configuration

```
save
```

- Confirmez ou appuyez sur Entrée pour sauvegarder dans `flash:/config.cfg`.

---

## 9. Se connecter depuis un PC via SSH

Assurez-vous que votre PC est sur le même sous-réseau que le switch (ex. 192.168.50.x).  
Depuis Windows PowerShell ou Linux/Mac :

```
ssh -oHostKeyAlgorithms=+ssh-rsa -oKexAlgorithms=+diffie-hellman-group14-sha1 -oCiphers=aes128-cbc -oMACs=hmac-sha1 admin@192.168.50.10
```

- Mot de passe : `MHSDhcd53`  
- Le prompt doit devenir `[HPE]`, indiquant que vous êtes en mode administrateur complet.

---

## 10. Commandes de vérification utiles

- Vérifier les utilisateurs locaux :  
```
display local-user
```

- Vérifier l’IP et l’état des interfaces :  
```
display ip interface brief
```

- Vérifier l’état du serveur SSH :  
```
display ssh server status
```

- Voir les sessions VTY actives :  
```
display users
```

---

## Notes importantes

- Sur Comware v5, si votre compte SSH n’a pas le niveau 3 ou que vous restez bloqué dans `<HPE>`, il faut utiliser la console physique ou faire un reset usine pour recréer un compte admin.  
- Pour le mot de passe, utilisez des caractères simples lors de la configuration initiale.  
- Les options SSH passées côté client (`KexAlgorithms`, `Ciphers`, `MACs`) sont nécessaires pour compatibilité avec ces anciens switchs HP.
