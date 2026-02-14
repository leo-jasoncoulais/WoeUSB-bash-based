#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
        echo "Le programme doit être éxecuté avec les permissions super administrateur."
        exit
fi

echo "Installation des dépendances..."
apt update -y >/dev/null 2>&1
apt upgrade -y >/dev/null 2>&1
apt install gdisk wimtools util-linux -y >/dev/null 2>&1

if ! [[ -e $1 ]]; then
        echo "Aucun fichier Windows n'est renseigné."
        exit
fi
if ! [[ -e $2 ]]; then
        echo "Aucun disque valide n'est renseigné."
        exit
fi

if [[ $(lsblk -ndo TYPE $2) -ne "disk" ]]; then
        echo "Vous devez renseigner un disque entier."
        exit
fi

mount -m $1 /mnt/install/tmp-$1 >/dev/null 2>&1
if [[ $? -ne 0 ]]; then echo "$1 n'a pas pu être monté."; exit; fi

if ! [[ -e /mnt/install/tmp-$1/sources/install.wim ]]; then
        echo "Le disque Windows fournit n'en est pas un. Pas de install.wim trouvé."
        umount /mnt/install/*
        exit
fi

echo -e "o\ny\nn\n1\n+0G\n+8G\n0700\nw\ny" | gdisk $2 >/dev/null 2>&1
if [[ $? -ne 0 ]]; then echo "$2 n'a pas pu être créé correctement."; umount /mnt/install/*; exit; fi

echo mkfs.fat -F 32 $2 >/dev/null 2>&1
if [[ $? -ne 0 ]]; then echo "$2 n'a pas pu être formaté en FAT32."; umount /mnt/install/*; exit; fi

mount -m "${2}1" /mnt/install/windows-key
if [[ $? -ne 0 ]]; then echo "$2 n'a pas pu être monté."; umount /mnt/install/*; exit; fi

echo "Copie des fichiers..."

cd /mnt/install/tmp-$1
find . -type f ! -name "install.wim" -exec cp --parents {} /mnt/install/windows-key \; >/dev/null 2>&1
cd - >/dev/null 2>&1

wimsplit /mnt/install/tmp-$1/sources/install.wim /mnt/install/windows-key/sources/install.swm 3800
if [[ $? -ne 0 ]]; then echo "Le fichier install.wim n'a pas pu être splitté."; umount /mnt/install/*; exit; fi

umount /mnt/install/*
rm -rf /mnt/install

echo "Terminé !"
