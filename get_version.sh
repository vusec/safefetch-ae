#!/bin/bash

if [[ "$*" == *"midas"* ]]
then
     echo -n midas
elif [[ "$*" == *"whitelist"* ]]
then
     echo -n whitelist
elif [[ "$*" == *"safefetch"* ]]
then
     echo -n safefetch
elif [[ "$*" == *"exploit"* ]]
then
     echo -n exploit
else
     echo -n no-version
fi
