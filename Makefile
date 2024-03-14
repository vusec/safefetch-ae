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

make all-paper: result paper

.PHONY: paper
