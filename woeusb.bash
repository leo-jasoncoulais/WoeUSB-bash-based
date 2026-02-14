#!/bin/bash

sudo echo "Installation des dépendances..."
sudo apt update -y >/dev/null 2>&1
sudo apt upgrade -y >/dev/null 2>&1
sudo apt install gdisk wimtools util-linux -y >/dev/null 2>&1

if ! [[ -e $1 ]]; then
	echo "Aucun fichier Windows n'est renseigné."
	exit
fi
if ! [[ -e $2 ]]; then
	echo "Aucun disque valide n'est renseigné."
	exit
fi

regex="block special .*\\([0-9]+/0)"
if ! [[ $(file $2) =~ $regex ]]; then
	echo "Vous devez renseigner un disque entier."
	exit
fi

sudo mount -m $1 /mnt/install/tmp-$1 >/dev/null 2>&1
if [[ $? -ne 0 ]]; then echo "$1 n'a pas pu être monté."; exit; fi

if ! [[ -e /mnt/install/tmp-$1/sources/install.wim ]]; then
	echo "Le disque Windows fournit n'en est pas un. Pas de install.wim trouvé."
	sudo umount /mnt/install/*
	exit
fi

echo -e "o\ny\nn\n1\n+0G\n+8G\n0700\nw\ny" | sudo gdisk $2 >/dev/null 2>&1
if [[ $? -ne 0 ]]; then echo "$2 n'a pas pu être créé correctement."; sudo umount /mnt/install/*; exit; fi

echo mkfs.fat -F 32 $2 >/dev/null 2>&1
if [[ $? -ne 0 ]]; then echo "$2 n'a pas pu être formaté en FAT32."; sudo umount /mnt/install/*; exit; fi

sudo mount -m "${2}1" /mnt/install/windows-key
if [[ $? -ne 0 ]]; then echo "$2 n'a pas pu être monté."; sudo umount /mnt/install/*; exit; fi

echo "Copie des fichiers..."
cp -r /mnt/tmp-$1/* /mnt/windows-key >/dev/null 2>&1
sudo wimsplit /mnt/install/tmp-$1/sources/install.wim /mnt/install/windows-key/sources/install.swm 4000 #>/dev/null 2>&1
if [[ $? -ne 0 ]]; then echo "Le fichier install.wim n'a pas pu être splitté."; sudo umount /mnt/install/*; exit; fi

sudo umount /mnt/install/*
sudo rm -rf /mnt/install

echo "Terminé !"
