
COMPILER=gcc
EXTRA_FLAGS=-j8 #V=1
SAFEFETCH_DIR=safefetch
MIDAS_DIR=midas
# Give some random unexisting SAVED_DIR as default (save_kernel will simply remove all other kernel but not install anything)
SAVED_DIR?=dummy
KERNEL_NAME=$(shell ./get_version.sh ${SAVED_DIR})
KERNEL_VERSION=$(shell ./get_version.sh $(shell uname -r))

setup:
	./setup.sh

governor:
	echo performance | sudo  tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

cpu_scaling: governor
	./warmup.sh

all_bench_timestamped: cpu_scaling
	BENCHNAME=${BUILD_STRING}-$$(date '+%d-%b-%g-%Hh%Mm') ;\
	./run_lmbench.sh $$BENCHNAME ;\
	./run_osbench.sh $$BENCHNAME ;\
	./run_phoronix.sh $$BENCHNAME ;\

all_bench: cpu_scaling
	BENCHNAME=${BUILD_STRING} ;\
	./run_lmbench.sh $$BENCHNAME ;\
	./run_osbench.sh $$BENCHNAME ;\
	./run_phoronix.sh $$BENCHNAME ;\

phoronix_result:
	cd ./playground/performance; \
	./phoronix_to_csv.sh; \

# Result aggregation
result: phoronix_result
	set -e; \
	cd ./playground/performance; \
	python3 ./lmbench_to_csv.py; \
	python3 ./osbench_to_csv.py; \
	set +e; \

# Result representation (write to pdf file)
paper: 
	cd ./playground/paper/scripts &&  python3 ./generate_plots.py && cd .. && make all && cd ../..

all-paper: result paper

# Kernel compilation
def_safefetch_config:
	make -C $(SAFEFETCH_DIR) mrproper
	make -C $(SAFEFETCH_DIR) x86_64_defconfig CC=$(COMPILER) LD=ld 

local_safefetch_config:
	make -C $(SAFEFETCH_DIR) mrproper
	yes "" | make -C $(SAFEFETCH_DIR) localmodconfig 
	cd $(SAFEFETCH_DIR); ./scripts/config -d CONFIG_DEBUG_INFO_BTF ; cd ..	

safefetch_config:
	cd $(SAFEFETCH_DIR); ./scripts/config -e CONFIG_SAFEFETCH; cd ..

compile_safefetch:
	yes "" | make -C $(SAFEFETCH_DIR) CC=$(COMPILER) LD=ld $(EXTRA_FLAGS)
	make -C $(SAFEFETCH_DIR) modules CC=$(COMPILER) LD=ld $(EXTRA_FLAGS)
	sudo make -C $(SAFEFETCH_DIR) modules_install CC=$(COMPILER) LD=ld $(EXTRA_FLAGS)
	sudo make -C $(SAFEFETCH_DIR) install CC=$(COMPILER) LD=ld $(EXTRA_FLAGS)

all_local_safefetch: local_safefetch_config safefetch_config compile_safefetch
all_default_safefetch: def_safefetch_config safefetch_config compile_safefetch

def_midas_config:
	make -C $(MIDAS_DIR) mrproper
	make -C $(MIDAS_DIR) x86_64_defconfig CC=$(COMPILER) LD=ld 

local_midas_config:
	make -C $(MIDAS_DIR) mrproper
	yes "" | make -C $(MIDAS_DIR) localmodconfig 
	cd $(MIDAS_DIR); ./scripts/config -d CONFIG_DEBUG_INFO_BTF ; cd ..	

midas_config:
	cd $(MIDAS_DIR); ./scripts/config -e CONFIG_TOCTTOU_PROTECTION; cd ..

compile_midas:
	yes "" | make -C $(MIDAS_DIR) CC=$(COMPILER) LD=ld $(EXTRA_FLAGS)
	make -C $(MIDAS_DIR) modules CC=$(COMPILER) LD=ld $(EXTRA_FLAGS)
	sudo make -C $(MIDAS_DIR) modules_install CC=$(COMPILER) LD=ld $(EXTRA_FLAGS)
	sudo make -C $(MIDAS_DIR) install CC=$(COMPILER) LD=ld $(EXTRA_FLAGS)

all_local_midas: local_midas_config midas_config compile_midas
all_default_midas: def_midas_config midas_config compile_midas


# Loading the kernel onto the machine
version:
	@echo $(KERNEL_VERSION)

clean_kernels:
	./save_kernel.sh -silent-clean safefetch
	./save_kernel.sh -silent-clean whitelist
	./save_kernel.sh -silent-clean midas
	./save_kernel.sh -silent-clean exploit
	sudo update-grub2

load_kernel: clean_kernels
	@echo Loading kernel $(KERNEL_NAME) from $(SAVED_DIR)
	./save_kernel.sh -restore $(KERNEL_NAME) $(SAVED_DIR)
	./configure_grub.sh

# Running performance artifact

run_performance_artifact:
	@echo Running performance artifact on local machine 
	./run_performance_artifact.sh $(KERNEL_VERSION)

#.PHONY: paper 
