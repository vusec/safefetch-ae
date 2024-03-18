#!/bin/bash
[[ -f backup_grub_default ]] && cat backup_grub_default | sudo tee /etc/default/grub
rm -f backup_grub_default
sudo update-grub2