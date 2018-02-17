[Source](https://wiki.alpinelinux.org/wiki/Classic_install_or_sys_mode_on_Raspberry_Pi)
# Install Alpine Linux on a RaspberryPi
## Prérequis
Une machine sous linux avec un accès à internet
## Preparation
Brancher la carteSD sur la la machine Linux.
Lister les disques et trouver celui qui correspond à la carteSD
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
- Créer une partition avec `n`, une partition primaire `p`, de numéro `1`, premier secteur `2048`, dernier secteur `+128M`
- Ajouter le flag bootable sur cette dernière `a`, puis `1`
- Changer le type de cette partition avec `t`, hexcode `0E`
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
/dev/sdb1            2048      264191      131072   83  Linux
/dev/sdb2          264192    30318591    15027200   83  Linux
```

Sauvgarder les changements et quitter avec `w`

### Formatage des partitions
Formater la partition 1 `/dev/sdb1` en **FAT16**
```sh
$ mkfs.vfat -F 16 /dev/sdg1
```

Formater la partition 2 `/dev/sdb2` en **ext4**
```sh
$ mkfs.ext4 /dev/sdg2
```

Il est possible de vérifier les types des partitions avec la command `cfdisk`

## Installation d'Alpine
Monter la partition 1 `/dev/sdb1` dans un repertoire courrant
```sh
$ mkdir alpine
$ mount /dev/sdb1 ./alpine
```
Vérifier que la partition est bien mounté avec la command `mount /dev/sdb1`

Télécharger l'archive RaspberryPi armhf depuis de le [site d'AlpineLinux](https://alpinelinux.org/downloads/)
Décompresser l'archive directement dans le repertoire de montage `alpine`
```sh
$ tar zxfv alpine-rpi-3.7.0-armhf.tar.gz -C ./alpine
$ ls ./alpine
apks                    bcm2835-rpi-a.dtb       bootcode.bin
bcm2708-rpi-0-w.dtb     bcm2835-rpi-a-plus.dtb  cmdline.txt
bcm2708-rpi-b.dtb       bcm2835-rpi-b.dtb       config.txt
bcm2708-rpi-b-plus.dtb  bcm2835-rpi-b-plus.dtb  fixup.dat
bcm2708-rpi-cm.dtb      bcm2835-rpi-b-rev2.dtb  overlays
bcm2709-rpi-2-b.dtb     bcm2835-rpi-zero.dtb    rpi.apkovl.tar.gz
bcm2710-rpi-3-b.dtb     bcm2836-rpi-2-b.dtb     start.elf
bcm2710-rpi-cm3.dtb     boot
```

Ajouter un fichier nomé `usercfg.txt` dans le repertoire `./alpine` et ajouter la ligne 
```toml
enable_uart=1
```

Démonter la partition et ejecter la carteSD
```sh
$ umount ./alpine
```

## Configuration d'Alpine Linux en mode sys
Après avoir installé Alpine Linux sur la carte SD et l'avoir placé dans le raspberryPi, booter le raspebrryPi.
Un écran sera necesaire dans un premier temps.

Se connecter en tant que `root`
### Setup-alpine
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
proxy: none
mirror: dl-cdn.alpinelinux.org
ssh server: openssh
ntp client: chrony
where to store config: none
cache directory: /tmp/cache
```

Next update package index with `apk`:
```sh
$ apk update
```

Installer l'utilitaire de disque et monter le disque `/dev/mmcblk0p2`
```sh
$ apk add e2fsprogs
$ mount /dev/mmcblk0p2 /mnt
```

Préparer la partition pour Alpine Linux
```sh
# Peut générer des erreurs (pas d'inquiétude)
# Et c'est long...
$ setup-disk -m sys /mnt
$ mount -o remount,rw /dev/mmcblk0p1
```

Nettoyer les boots folders
```sh
$ rm -f /media/mmcblk0p1/boot/*
$ rm /mnt/boot/boot
```

Déplacer les fichiers de boot qui viennent d'être générés
```sh
$ cd /mnt
$ mv boot/* /media/mmcblk0p1/boot/
$ rm -rf boot
$ mkdir media/mmcblk0p1
# Ne pas faire attention à l'erreur
$ ln -s media/mmcblk0p1/boot boot
```

Mise à jour de la table de montage `fstab`
Ajouter la ligne dans le fichier `/etc/fstab`
Si une ligne commençant de la même façon existe déjà, il faut la supprimer
```sh
/dev/mmcblk0p1 /media/mmcblk0p1 vfat defaults 0 0
```

Supprimer toutes les lignes autres lignes inutiles. Notament `floppy` et `cdrom`
Redémarrer
```sh
$ reboot
```

Si tout s'est bien passé, vérifier sur quel disque `/` a été monté avec la command `df`. Ce devrait être `/dev/mmcblk0p2`

### Bonus
#### Ajouter les dépos de la communauté.
Dans le fichier `/etc/apk/repositories` décomenter la ligne `https://dl-cdn.../comunnity/..`

#### Configurer l'heure
Les raspberryPi n'ont pas de pile interne. Donc en cas de redémarrage, le temps doit être synchronisé avec un serveur **ntp**
```sh
rc-update del hwclock boot
rc-update add swclock boot
service hwclock stop
service swclock start
```
