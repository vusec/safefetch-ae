import os
import export_csv

root_dir = "./osbench"
blueprint = [
    "Create/teardown of 100 threads",
    "Create/teardown of 100 processes",
    "Launch 100 programs",
    "Create/delete 65534 files",
    "Allocate/free 1000000 memory chunks"
]

def extract_val(k, data):
    for i, l in enumerate(data):
        if k in l:
            return float(data[i+1].split(" ")[0])
extract_val_func = extract_val


# Loop over all the unique OSBench benchmarks that are found within the performance dir
for x in os.listdir(root_dir):
    bench_dir = root_dir + "/" + x

    # Ignore non-directory entries
    if not os.path.isdir(bench_dir):
        continue

    # Extract all the values for that benchmark and convert it to a dictionary
    dir_values = export_csv.extract_values(bench_dir, blueprint, extract_val_func)

    # Compute statistics and export the computed values to a csv file
    export_csv.export_to_csv(root_dir, bench_dir, len(dir_values[blueprint[0]]), dir_values)