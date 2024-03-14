import os
import numpy as np

csv_header = "bench;avg;med;stddev;lowest;highest;cv\n"


# This function checks if all the benchmarks inside the blueprint are inside
# the array of strings called f_data
def check_all_benches_present(blueprint, f_data):
    def k_check(k, list):
        for l in list:
            if k in l:
                return 1
        return 0
    for k in blueprint:
        if not k_check(k, f_data):
            return 0
    return 1


# This function extracts all the values from the files within a specific benchmark directory
# It extracts and groups the values based on the unique benchmarks
# It returns a dictionary with the benchmarks as keys linked to a list of extracted values
def extract_values(bench_dir, blueprint, extract_val_func):
    # Dictionary blueprint
    data = {x: [] for x in blueprint}

    # Loop over all the benchmark results files inside the benchmark dir
    for f_name in os.listdir(bench_dir):
        # Ignore older results files
        if f_name == "bandwidth_results.csv" or f_name == "results.csv":
            continue

        # Extract the data
        f = open(bench_dir + "/" + f_name, errors="ignore")
        f_data = f.readlines()
        f.close()

        # Check if all the unique tests were performed
        if not check_all_benches_present(blueprint, f_data):
            print("error invalid benchmark data file! Ignoring {} from {}".format(f_name, bench_dir))
            continue

        # Extract the values from the file into the dictionary
        for k in data.keys():
            data[k] += [extract_val_func(k, f_data)]
    data_new = {}
    for elem in data.keys():
        correct = elem.strip("\"")
        data_new[correct] = data[elem]
    return data_new

cv = lambda x: np.std(x, ddof=1) / np.mean(x) * 100 
var =  lambda x, y: float(x / y)

# This function computes the results that will be exported to the csv file
def compute_results(data):
    np_data = np.array(data)
    avg = np.mean(np_data)
    med = np.median(np_data)
    stddev = np.std(np_data)
    low = np.amin(np_data)
    high = np.amax(np_data)
    var1 = var(stddev, avg)
    return avg, med, stddev, low, high, var1


# This function generates a CSV with a header and rows of computes results
# First line states type of benchmark
# Second line states benchmark name and the amount of runs incorporated
# Third line states the csv file structure
# Fourth line (and further) contains the data
# The csv file is stored within the benchmarking directory
def export_to_csv(root_dir, bench_dir, num_vals, val_dict):
    f = open(bench_dir + "/results.csv", "w")
    f.write("# {} benchmarking results\n".format(root_dir))
    f.write("# Name: {}, runs: {}\n".format(bench_dir, num_vals))
    f.write(csv_header)
    for k, v in val_dict.items():
        f.write("{};".format(k))
        for r in compute_results(v):
            f.write("{};".format(r))
        f.write("\n".format(k))
    f.close()
