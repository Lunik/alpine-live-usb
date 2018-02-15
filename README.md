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
$ mkfs.msdos -F 16 /dev/sdg1
```

Formater la partition 2 `/dev/sdb2` en **ext4**
```sh
$ mkfs.ext4 /dev/sdg2
```

Il est possible de vérifier les types des partitions avec la command `cfdisk`

### Installation d'Alpine
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