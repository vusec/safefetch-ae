#!/bin/bash
. global_exports.sh
if [[ $1 == '-save' ]];
then
    [[ !  -z  $2  ]] && echo KernelName: $2 || exit
    [[ !  -z  $3  ]] && echo Saved: $3 || exit
    sudo rm -rf playground/kernels/$3
    mkdir -p playground/kernels/$3
    sudo cp /boot/*-${2}+ playground/kernels/$3/.
    sudo cp -r /lib/modules/${KERNEL_VERSION}-$2+ playground/kernels/$3/.
elif [[ $1 == '-restore' ]];
then
    [[ !  -z  $2  ]] && echo KernelName: $2 || exit 125
    [[ !  -z  $3  ]] && echo Saved: $3 || exit 125
    if [[ ! -d playground/kernels/$3 ]];
    then 
        sudo update-grub2
        echo "Error - no kernel directory named:"$3
        exit 125
    fi

    if [[ $2 == "no-version" ]]; 
    then
        sudo update-grub2 
        echo "Error - trying to load a non-stock kernel - no-version"
        exit 125
    fi       
    sudo rm -rf /boot/*-${2}+
    sudo rm -rf /lib/modules/${KERNEL_VERSION}-$2+
    sudo cp playground/kernels/$3/*-${2}+ /boot/.
    sudo cp -r --no-preserve=links playground/kernels/$3/${KERNEL_VERSION}-$2+ /lib/modules/.
    sudo update-grub2
elif [[ $1 == '-clean' ]];
then
    [[ !  -z  $2  ]] && echo KernelName: $2 || exit
    sudo rm -rf /boot/*-${2}+
    sudo rm -rf /lib/modules/${KERNEL_VERSION}-$2+
    sudo update-grub2
elif [[ $1 == '-silent-clean' ]];
then
    [[ !  -z  $2  ]] && echo KernelName: $2 || exit
    sudo rm -rf /boot/*-${2}+
    sudo rm -rf /lib/modules/${KERNEL_VERSION}-$2+
fi


