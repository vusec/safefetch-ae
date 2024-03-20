#!/bin/bash
. global_exports.sh

# Clone safefetch in case it doesn't exist
[[ ! -d safefetch ]] &&  git clone ${SAFEFETCH_REPO}
[[ ! -d playground/kernels/safefetch-default ]] && ./save_kernel.sh -clean safefetch

[[ ! -d playground/kernels/safefetch-default ]] && cd safefetch && git checkout main && cd .. && make all_default_safefetch  && ./save_kernel.sh -save safefetch safefetch-default && echo '##Compiled safefetch (default config)'


[[ ! -d playground/kernels/safefetch-local ]] && ./save_kernel.sh -clean safefetch

[[ ! -d playground/kernels/safefetch-local ]] && cd safefetch && git checkout main && cd .. && make all_local_safefetch  && ./save_kernel.sh -save safefetch safefetch-local && echo '##Compiled safefetch (local config)'

[[ -f /boot/vmlinuz-5.11.0-safefetch+ ]] && ./save_kernel.sh -clean safefetch

[[ ! -d playground/kernels/exploit-default ]] && ./save_kernel.sh -clean exploit

[[ ! -d playground/kernels/exploit-default ]] && cd safefetch && git checkout exploit && cd .. && make all_default_safefetch  && ./save_kernel.sh -save exploit exploit-default && echo '##Compiled safefetch-exploit (default config)'


[[ ! -d playground/kernels/exploit-local ]] && ./save_kernel.sh -clean exploit

[[ ! -d playground/kernels/exploit-local ]] && cd safefetch && git checkout exploit && cd .. && make all_local_safefetch  && ./save_kernel.sh -save exploit exploit-local && echo '##Compiled safefetch-exploit (local config)'

[[ -f /boot/vmlinuz-5.11.0-exploit+ ]] && ./save_kernel.sh -clean exploit

if [[ "$*" == *"-whitelist"* ]]
then
     [[ ! -d playground/kernels/whitelist-default ]] && ./save_kernel.sh -clean whitelist

     [[ ! -d playground/kernels/whitelist-default ]] && cd safefetch && git checkout whitelist && cd .. && make all_default_safefetch  && ./save_kernel.sh -save whitelist whitelist-default && echo '##Compiled safefetch-whitelist (default config)'


     [[ ! -d playground/kernels/whitelist-local ]] && ./save_kernel.sh -clean whitelist

     [[ ! -d playground/kernels/whitelist-local ]] && cd safefetch && git checkout whitelist && cd .. && make all_local_safefetch  && ./save_kernel.sh -save whitelist whitelist-local && echo '##Compiled safefetch-whitelist (local config)'

     [[ -f /boot/vmlinuz-5.11.0-whitelist+ ]] && ./save_kernel.sh -clean whitelist
fi




if [[ "$*" == *"-midas"* ]]
then
     [[ ! -d midas ]] &&  git clone ${MIDAS_REPO}

     [[ ! -d playground/kernels/midas-default ]] && ./save_kernel.sh -clean midas

     [[ ! -d playground/kernels/midas-default ]] &&  make all_default_midas  && ./save_kernel.sh -save midas midas-default && echo '##Compiled midas (default config)'


     [[ ! -d playground/kernels/midas-local ]] && ./save_kernel.sh -clean midas

     [[ ! -d playground/kernels/midas-local ]] && make all_local_midas  && ./save_kernel.sh -save midas midas-local && echo '##Compiled midas (local config)'

     [[ -f /boot/vmlinuz-5.11.0-midas+ ]] && ./save_kernel.sh -clean midas
fi

