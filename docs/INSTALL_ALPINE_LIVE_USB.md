# Install Alpine Linux on a RaspberryPi
## Prérequis
Une machine sous linux avec un accès à internet
## Preparation
Brancher la clé USB sur la la machine Linux.
Lister les disques et trouver celui qui correspond à la clé
```sh
$ fdisk -l
Disque /dev/sdb : 15.5 Go, 15523119104 octets, 30318592 secteurs
Unités = secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 512 octets / 512 octets
Type d'étiquette de disque : dos
Identifiant de disque : 0xd8fe63fd
```

### Partitionnement de la carte SD
Éditer la table des partitions avec la commande `fdisk /dev/sdb`
- Supprimer toutes les partitions avec la touche `d` (à refaire tant qu'il en reste)
- Lister les partitions avec `p`
- Créer une partition avec `n`, une partition primaire `p`, de numéro `1`, premier secteur `2048`, dernier secteur `+1,5G`
- Ajouter le flag bootable sur cette dernière `a`, puis `1`
- Créer une seconde partition primaire, `n`, `p`, `2` , premier secteur et dernier secteur par défaut

Avec la touche `p`, il devrait apparaitre deux partitions tel que:
```sh
Commande (m pour l'aide) : p

Disque /dev/sdb : 15.5 Go, 15523119104 octets, 30318592 secteurs
Unités = secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 512 octets / 512 octets
Type d'étiquette de disque : dos
Identifiant de disque : 0xd8fe63fd

Périphérique Amorçage  Début         Fin      Blocs    Id. Système
/dev/sdb1    *       2048      264191      131072   83  Linux
/dev/sdb2          264192    30318591    15027200   83  Linux
```

## Installation d'Alpine
Télécharger l'image RaspberryPi `standard` depuis de le [site d'AlpineLinux](https://alpinelinux.org/downloads/)

Utiliser `QEMU` pour booter l'image alpine
```sh
$ qemu-system-x86_64 -hda /dev/sdb -boot menu=on -drive file=alpine-standard-3.7.0-x86_64.iso
```
Appuyer sur `F12` pour accerder au menu de boot. Choisir l'option `2`
Le système boot alors sur l'image disque d'Alpine

Se connecter en tant que `root`
### Setup-alpine
Si il y a un proxy
```sh
$ export HTTP_PROXY=<URL_DU_PROXY>
```

Utilisation du script préinstallé d'alpine pour faire les configurations de base
```sh
$ setup-alpine
keyboard layout: fr
variant: fr-azerty
hostname: alpine
initialise interface: eth0
ip address: dhcp
manual config: no
password: ****
timezone: Europe/Paris
proxy: none // Sauf si necessaire
mirror: dl-cdn.alpinelinux.org
ssh server: none
ntp client: chrony
where to store config: none
cache directory: /tmp/cache
```

Next update package index with `apk`:
```sh
$ apk update
```

## Setup-disk
```sh
$ setup-disk
disk: sda
mode: sys
overwrite: yes
```

### Bonus
#### Ajouter les dépos de la communauté.
Dans le fichier `/etc/apk/repositories` décomenter la ligne `https://dl-cdn.../comunnity/..`
