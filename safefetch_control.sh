#!/bin/bash

# Hook initialization has to be a one time only event.
XSLEEP=2

init_defense () {
    if [[ $1 == '-linklist' ]];
    then
       CONFIG=0
    elif [[ $1 == '-rbtree' ]];
    then
       CONFIG=1
    elif [[ $1 == '-adaptive' ]];
    then
       CONFIG=2
    elif [[ $1 == '-storage' ]];
    then
       # When updating the region sizes flip off defense (we don't want
       # concurent accesses).
       echo "0" | sudo tee /sys/dfcacher_keys/copy_from_user_key_ctrl
       sleep ${XSLEEP}

       echo "$2 $3 $4" | sudo tee /sys/dfcacher_keys/storage_regions_ctrl

       echo "1" | sudo tee /sys/dfcacher_keys/copy_from_user_key_ctrl
       sleep ${XSLEEP}

       return 0 
    elif [[ $1 == '-hooks' ]];
    then
       # Warning call this once, and it can never be set to 0 on this run.
       echo "1" | sudo tee /sys/dfcacher_keys/hooks_key_ctrl
       sleep ${XSLEEP}
       return 0 
    elif [[ $1 == '-enable' ]];
    then
       # We would like to flip defense hooks as well but this causes a race condition.
       #echo "1" | sudo tee /sys/dfcacher_keys/hooks_key_ctrl
       #sleep ${XSLEEP}
       # Just turn off defense if we get a different param
       echo "1" | sudo tee /sys/dfcacher_keys/copy_from_user_key_ctrl
       sleep ${XSLEEP}
       echo "Enabled DFCacher"
       return 0   
    else
       # Just turn off defense if we get a different param
       echo "0" | sudo tee /sys/dfcacher_keys/copy_from_user_key_ctrl
       sleep ${XSLEEP}
       echo "Disabled DFCacher"
       return 0    
    fi

    # Disable user copy protection.
    echo "0" | sudo tee /sys/dfcacher_keys/copy_from_user_key_ctrl
    sleep ${XSLEEP}

    [[ !  -z  $2  ]] &&  echo "$2 $3 $4" | sudo tee /sys/dfcacher_keys/storage_regions_ctrl
    sleep ${XSLEEP}

    if [ "$CONFIG" == "2" ]; then  
        [[ !  -z  $5  ]] &&  echo "$5" | sudo tee /sys/dfcacher_keys/adaptive_watermark_ctrl
        sleep ${XSLEEP}
    fi

    # Modify defense configuration
    echo ${CONFIG} | sudo tee /sys/dfcacher_keys/defense_config_ctrl
    sleep ${XSLEEP}

    # Bring copy from user hooks back online.
    echo "1" | sudo tee /sys/dfcacher_keys/copy_from_user_key_ctrl
    sleep ${XSLEEP}

    echo "Defense Configuration:  "$1 $2 $3

    return 0
}

init_defense $1 $2 $3 $4 $5



