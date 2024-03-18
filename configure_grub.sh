#!/bin/bash
sudo rm -f intermediary_grub.cfgs
rm -f intermediary_grub.default

if [ ! -f /etc/default/grub ]; then
 echo "Error - /etc/default/grub does not exist on your system"
 exit
fi

match_grub_default=$(cat /etc/default/grub | grep ^GRUB_DEFAULT | wc -l)
echo $match_grub_default
if [ $match_grub_default = "0" ]; then
  echo "Error - Add [GRUB_DEFAULT=0] (without surrounding parantheses) at the beginning of /etc/default/grub"
  exit
fi


sudo grub-mkconfig -o intermediary_grub.cfgs

cat intermediary_grub.cfgs | grep -iE "menuentry 'Ubuntu, with Linux" | awk '{print i++ " : "$1, $2, $3, $4, $5, $6, $7}'

nconfigs=$(cat intermediary_grub.cfgs | grep -iE "menuentry 'Ubuntu, with Linux"| wc -l)
nconfigs=$((nconfigs - 1))

echo Max config number:${nconfigs}

echo 'Select which of the above kernels you want to boot in by default: (eg. 0, 1, 2 ... etc)'

echo -n 'Select kernel number:'
read number

sudo rm intermediary_grub.cfgs

if [ "$number" -gt "$nconfigs" ]; then
  echo 'Error- trying to boot by default inexistent kernel index'
  exit
fi


if [ ! -f backup_grub_default ]; then
   echo 'Backing up grub default file'
   cp /etc/default/grub backup_grub_default
fi
cat /etc/default/grub | sed "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=\"1>${number}\"/g" > intermediary_grub.default
cat intermediary_grub.default | sudo tee /etc/default/grub
rm intermediary_grub.default

sudo update-grub2
