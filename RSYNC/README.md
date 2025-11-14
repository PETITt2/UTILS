# RSYNC + CRONTAB
---
## Sauvegardes automatiques avec rsync et crontab
*Comment utiliser l'outils rsync sous linux pour configurer un systeme de sauvegarde automatique avec crontab. Cela inclus la creation de script pour faire la sauvegarde et l'envoyer sur une machine distante (ssh) et l'execution de ce script sera automatisé par contab.*


---
#### Note : Tout les script sont a adapter il y a des @IP, des user et repertoires qui sont a creer ou a modifier avec la bonne dénomination
---


## 1. Prérequis

Avant de commencer, assurez-vous que les outils suivants sont installés
:
```requirement

-   rsync
-   cron (ou cronie selon la distribution)
-   scp (souvent inclus avec OpenSSH)
-   ssh-keygen (pour l'authentification sans mot de passe)
```

Installation sous Debian/Ubuntu :
```cmd
    sudo apt install rsync openssh-client
```
Installation sous CentOS/RHEL :
```cmd
    sudo yum install rsync openssh-clients
```

## 2. Création du script de sauvegarde

Créer un fichier de script :
```cmd
    backup_rsync.sh
```
Contenu du script :

``` bash
#!/bin/bash

# Configuration

SOURCE="/home/user/dossier_a_sauvegarder/"
DEST="/home/user/backups/"

REMOTE_USER="root"
REMOTE_HOST="192.168.50.2"
REMOTE_PATH="/home/backup_remote/"

LOG="/home/user/rsync_backup.log"

echo "=== Début backup local $(date) ===" >> "$LOG"

# Sauvegarde locale avec rsync
rsync -avh --delete "$SOURCE" "$DEST" --log-file="$LOG"

echo "=== Envoi des fichiers via SCP $(date) ===" >> "$LOG"

# Envoi des fichiers vers une autre machine
scp -r "$DEST"/* "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH" >> "$LOG" 2>&1

echo "=== Fin du backup $(date) ===" >> "$LOG"
```

Rendre le script exécutable :

    chmod +x backup_rsync.sh

## 3. Vérification du script

Exécuter manuellement :
```cmd
    backup_rsync.sh
```
Vérifier les logs :

    rsync_backup.log

## 4. Configuration SSH sans mot de passe

Générer une clé :

    ssh-keygen

Copier vers la machine distante :

    ssh-copy-id remote_user@192.168.1.50

## 5. Configuration cron

Ouvrir la crontab :

    crontab -e

Exécuter chaque jour à 3h :

    0 3 * * * backup_rsync.sh

## 6. Vérification cron

    grep CRON /var/log/syslog

## 7. Notes importantes

1.  Utiliser des chemins absolus.
2.  Vérifier les permissions.
3.  Tester rsync avec --dry-run.
4.  Vérifier les logs régulièrement.

## 8. Structure recommandée

    /home/user/
        backup_rsync.sh
        rsync_backup.log
        dossier_a_sauvegarder/
        backups/

## 9. Dépannage

### Fonctionne manuellement mais pas avec cron

Ajouter au début du script :

``` bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

### si SCP demande un mot de passe

Vérifier ssh-copy-id.
(verifier la key)
