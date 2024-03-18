# importing package
import matplotlib.pyplot as plt
import numpy as np
import csv
import os
from matplotlib.axis import Axis
import matplotlib
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

source_file_path = "../../performance/"
security_file_path = "../../security/"
benchmark_suites = ["lmbench", "lmbench_bandwidth", "osbench", "phoronix"]
#benchmark_suites = ["lmbench", "osbench"]
result_file = "results.csv"
bandwidth_file = "bandwidth_results.csv"

target_result_column = "med"

baseline_pattern = "baseline"

enable_debug = True

output_configs = [1, 0]

config_patterns = [ "baseline", "safefetch", "whitelist", "midas" ]
security_patterns = ["baseline", "safefetch"]


lmbench_blueprint = [
    "Simple syscall",
    "Simple read",
    "Simple write",
    "Simple stat",
    "Simple fstat",
    "Simple open/close",
    "Select on 10 fd's",
    "Select on 100 fd's",
    "Select on 250 fd's",
    "Select on 500 fd's",
    "Select on 10 tcp fd's",
    "Select on 100 tcp fd's",
    "Select on 250 tcp fd's",
    "Select on 500 tcp fd's",
    "Signal handler installation",
    "Signal handler overhead",
    "Protection fault",
    "Pipe latency",
    "AF_UNIX sock stream latency",
    "Process fork+exit",
    "Process fork+execve",
    "Process fork+/bin/sh",
    "TCP latency using localhost",
    "UDP latency using localhost",
    "TCP/IP connection cost to localhost"
]

lmbench_simplified_names = { "Signal handler installation" : "Sig. handler install", "Signal handler overhead" : "Sig. handler overhead", "AF_UNIX sock stream latency" : "AF_UNIX latency",
                              "TCP/IP connection cost to localhost" : "TCP conn. latency", "TCP latency using localhost" : "TCP latency" , "UDP latency using localhost" : "UDP latency" }


bandwidth_blueprints = [
    "read bandwidth",
    "read open2close bandwidth",
    "Mmap read bandwidth",
    "Mmap read open2close bandwidth",
    "libc bcopy unaligned",
    "libc bcopy aligned", 
    "Memory bzero bandwidth",
    "unrolled bcopy unaligned",
    "unrolled partial bcopy unaligned",
    "Memory read bandwidth",
    "Memory partial read bandwidth",
    "Memory write bandwidth",
    "Memory partial write bandwidth",
    "Memory partial read/write bandwidth",
    "Socket bandwidth using localhost",
    "AF_UNIX sock stream bandwidth",
    "Pipe bandwidth",
    "File /var/tmp/XXX write bandwidth"
]

ignore = [
    "AFUNIX sock stream bandwidth",
    "Pipe bandwidth",
    "File /var/tmp/XXX write bandwidth"    
]

osbench_blueprint = [
    "Create/teardown of 100 threads",
    "Create/teardown of 100 processes",
    "Launch 100 programs",
    "Create/delete 65534 files",
    "Allocate/free 1000000 memory chunks"
]

phoronix_blueprint = ["IPC", "openssl", "pybench", "Redis-G", "Redis-S", "git", "nginx" , "apache"]

blueprints = {
    "lmbench": lmbench_blueprint,
    "lmbench_bandwidth" : bandwidth_blueprints,
    "osbench": osbench_blueprint,
    "phoronix": phoronix_blueprint
}

labels = {
    "lmbench": {
        "yaxis": "Microseconds"
    },
    "osbench": {
        "yaxis": "Relative performance (%)",
        "title" : "OSBench Results",
        "x-names" : {"Create/teardown of 100 threads" : "Create\nThread", "Create/teardown of 100 processes" : "Create\nProcess" , "Create/delete 65534 files" : "Create\nFile" , "Allocate/free 1000000 memory chunks" : "Memory\nAlloc" , "Launch 100 programs" : "Launch\nProgram" },
        "legend-keywords" : { "baseline" : "Baseline" , "midas" : "Midas", "whitelist" : "SafeFetch-whitelist", "safefetch" : "SafeFetch-default" },
        "x-axis-label-rotation" : 0,
        "x-axis-label-pad" : 20 ,
        "legend-x-anchor" : 0.04,
        "text-y-anchor" : 0.20
    },

    "phoronix": {
        "yaxis": "Relative performance (%)",
        "title" : "Phoronix Results",
        "x-names" : {},
        "legend-keywords" : { "baseline" : "Baseline" , "midas" : "Midas", "whitelist" : "SafeFetch-whitelist", "safefetch" : "SafeFetch-default" },
        "x-axis-label-rotation" : 0,
        "x-axis-label-pad" : 20,
        "legend-x-anchor" : 0.05,
        "text-y-anchor" : 0.20
    },
    "npb": {
        "yaxis": "Seconds"
    },
}


def get_simplified_xaxis_names(benchmark, benchmark_blueprint):
    simplified_xaxis = []
    for xmember in benchmark_blueprint:
        if xmember in labels[benchmark]["x-names"]:
           simplified_xaxis += [ labels[benchmark]["x-names"][xmember] ]
        else:
           simplified_xaxis += [ xmember ]
    return simplified_xaxis
def search_keywords(benchmark, keywords):
    for keyword in reversed(keywords):
        if keyword in labels[benchmark]["legend-keywords"]:
           return labels[benchmark]["legend-keywords"][keyword]
    return "notfound"


def find_all_valid_benchmark_result_dirs(root_path):
    benchmark_result_dirs = []
    for bench_dir in os.listdir(root_path):
        if not os.path.isdir(root_path+"/"+bench_dir):
            continue
        if not os.path.exists(root_path+"/"+bench_dir+"/"+result_file) or not os.path.isfile(root_path+"/"+bench_dir+"/"+result_file):
            continue
        benchmark_result_dirs += [root_path+"/"+bench_dir]
    benchmark_result_dirs.sort()
    return benchmark_result_dirs

def select_benchmark_dirs(path, is_paper):
    bench_dirs = find_all_valid_benchmark_result_dirs(path)

    final_bench_dirs = []
    found_baseline = False

    for iconfig in config_patterns:
        config = iconfig
        if (is_paper):
            config = config + "-paper"
        for i in range(len(bench_dirs)):
            if  bench_dirs[i].endswith(config):
                if "baseline" in config:
                    found_baseline = True
                final_bench_dirs.append(bench_dirs[i])

    if not found_baseline:
        return None

    print("Selected the following configs:{}".format(final_bench_dirs))
    
    return final_bench_dirs

def select_security_dirs(path, file):
    bench_dirs = find_all_valid_benchmark_result_dirs(path)
    final_bench_dirs = []

    for i in range(len(bench_dirs)):
        if  bench_dirs[i].endswith(file):
                final_bench_dirs.append(bench_dirs[i])

    if (len(final_bench_dirs) != 1):
        return None

    print("Selected the following configs:{}".format(final_bench_dirs))
    
    return final_bench_dirs

def aggregate_numeric_security_results(bench_dirs, target_column):
    bench_results = []
    for b in bench_dirs:
        with open(b+"/"+result_file) as csv_file:
            csv_dict = csv.DictReader(filter(lambda row: row[0]!='#', csv_file), delimiter=';')
            for row in csv_dict:
                bench_results.append(int(row[target_column]))
    return bench_results


def aggregate_numeric_results(bench_dirs, target_column):
    bench_results = {}
    for b in bench_dirs:
        with open(b+"/"+result_file) as csv_file:
            csv_dict = csv.DictReader(filter(lambda row: row[0]!='#', csv_file), delimiter=';')
            result_dict = {}
            for row in csv_dict:
                result_dict[row["bench"]] = float(row[target_column])
            bench_results[b] = result_dict
    return bench_results

def aggregate_column(bench_dirs, target_column):
    bench_results = {}
    for b in bench_dirs:
        with open(b+"/"+result_file) as csv_file:
            csv_dict = csv.DictReader(filter(lambda row: row[0]!='#', csv_file), delimiter=';')
            result_dict = {}
            for row in csv_dict:
                result_dict[row["bench"]] = row[target_column]
            bench_results[b] = result_dict
    return bench_results

def plot_normalized_barchart(bechnmark, bench_results, stddev_results, bench_blueprint, direction, savefile):
    plt.clf()
    result_lists = {}
    stddev_lists = {}
    baseline_results = []
    print("Plotting results for {}...".format(benchmark))
    for bench_name, bench_values in bench_results.items():
        result_list = []
        stddev_list = []
        for b in bench_blueprint:
            result_list += [float(bench_values[b])]
            stddev_list += [float(stddev_results[bench_name][b])]
        result_lists[bench_name] = result_list
        stddev_lists[bench_name] =  stddev_list
    for target in result_lists.keys():
        if baseline_pattern in target:
           baseline_results = result_lists[target]
           result_lists.pop(target)
           base_stdev = stddev_lists.pop(target)
           break
    base_arr = np.array(baseline_results)

    fig, ax = plt.subplots()


    i = 0
    bar_arr = []
    for k,v in result_lists.items():
        normalized_arr = np.divide(base_arr, np.array(v))
        # use delta approximation for stdev of inverse
        delta_std = np.divide(np.array(stddev_lists[k]), np.square(np.array(v)))
        var_arr = np.divide(delta_std, np.divide(np.ones(len(base_arr)),base_arr))

        # Patch LIB benchmarks
        if direction != None:
         for j in range(len(bench_blueprint)):
           if direction[k][bench_blueprint[j]] == 'HIB':
               normalized_arr[j] = v[j]/base_arr[j]
               delta_std[j] = stddev_lists[k][j]
               var_arr[j] = delta_std[j]/base_arr[j]

        label = search_keywords(benchmark , k.split("/")[-1].split("-"))
        x = np.arange(len(bench_blueprint)) * 1.6
        bar_arr += [ax.bar(x+(-0.4 + i*0.4), normalized_arr, 0.4, label=label, edgecolor = "black")]
        ax.errorbar(x+(-0.4 + i*0.4), normalized_arr, yerr=var_arr,  linestyle='None', color='k', markersize=4, capsize=2,  elinewidth=0.5)

        for j in range(len(bench_blueprint)):
           ax.text(x[j]+(-0.4 + i*0.4), normalized_arr[j] - labels[benchmark]["text-y-anchor"], "{}".format(round(normalized_arr[j]*100, 1)), verticalalignment='baseline', horizontalalignment='center', rotation='vertical')
        
        i += 1
    ax.set_ylabel(labels[benchmark]["yaxis"])
    ax.set_xticks(np.arange(len(bench_blueprint)) * 1.6)
    ax.set_xticklabels(get_simplified_xaxis_names(benchmark, bench_blueprint))


    plt.xticks(fontsize=10, fontweight='bold', rotation = labels[benchmark]["x-axis-label-rotation"])

    ax.xaxis.labelpad = labels[benchmark]["x-axis-label-pad"]


    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    ax.legend(bbox_to_anchor=(0.5, 1.1), loc='upper center', ncol=len(result_lists.keys()))
    plt.axhline(y=1.0, color='black', linestyle='--', linewidth=0.5, dashes=(5, 1))

    plt.tight_layout()

    fig.savefig(savefile)

def print_results(benchmark, bench_results, stddev_results, bench_blueprint, direction):
    result_lists = {}
    stddev_lists = {}
    baseline_results = []
    print("Printing results for {}...".format(benchmark))
    for bench_name, bench_values in bench_results.items():
        result_list = []
        stddev_list = []
        for b in bench_blueprint:
            result_list += [float(bench_values[b])]
            stddev_list += [float(stddev_results[bench_name][b])]
        result_lists[bench_name] = result_list
        stddev_lists[bench_name] =  stddev_list
    for target in result_lists.keys():
        if baseline_pattern in target:
           baseline_results = result_lists[target]
           result_lists.pop(target)
           stddev_lists.pop(target)
           break
    base_arr = np.array(baseline_results)
    header = "Benchmarks"
    trailer = "{}{}/".format(source_file_path, benchmark)
    for target in result_lists.keys():
        header = "{} {}".format(header, target.replace(trailer, ""))
    columns = {}
    geo_means = {}
    geo_means_inv = {}
    for bench_name, list_results in result_lists.items():
        ovr_arr = np.subtract(np.multiply(np.divide(np.array(list_results), base_arr), 100.0) , 100.0)
        var_arr = np.multiply(np.divide(np.array(stddev_lists[bench_name]), base_arr), 100.0)

        ratio = np.divide(np.array(list_results), base_arr)
        geo_means[bench_name] = ((ratio).prod())**(1.0/len(base_arr))

        # Calculate inv geomean, for phoronix compute performance geomean
        # use ratio for HIB like bandwidth and inverse ratio for time spent.
        # - means overhead + means 
        geo_means_inv[bench_name] = np.divide(base_arr,np.array(list_results))
        
        if direction != None:
         for j in range(len(bench_blueprint)):
           if direction[bench_name][bench_blueprint[j]] == 'HIB':
               geo_means_inv[bench_name][j] = ratio[j]
        
        geo_means_inv[bench_name] = (geo_means_inv[bench_name].prod())**(1.0/len(base_arr))
        columns[bench_name] = {}
        columns[bench_name]["ovr"] = ovr_arr
        columns[bench_name]["var"] = var_arr
    i = 0
    print(header)
    for b in bench_blueprint:
        line = "{:40}".format(b)
        for target in result_lists.keys():
            line = "{} {:10}%".format(line, round(columns[target]["ovr"][i],2))
            line = "{} {:10}%".format(line, round(columns[target]["var"][i],1))
        print(line)
        i = i + 1
    line = "{:40}".format("Geo mean.")
    for target in result_lists.keys():
        line = "{} {:10}%".format(line, round(((geo_means[target] - 1.0) * 100.0), 1))
        line = "{} {:10}%".format(line, round(((geo_means_inv[target] - 1.0) * 100.0), 1))
    print(line) 

config_values = ["SafeFetch-Default", "SafeFetch-Whitelist", "Midas"]

def get_config_opts(configs):
    initial_options = [0, 0 , 0]
    for config in configs:
      if ("whitelist" in config):
         initial_options[1] = 1
      if ("safefetch" in config):
         initial_options[0] = 1
      if ("midas" in config):
         initial_options[2] = 1
    return initial_options

def generate_latex_performance_table_header(table_file, config_opts):
   # Create main latex table header
   if enable_debug:
      print("Config options are: {}".format(config_opts))
   table_header = "\\begin{tabular}{l|r"
   unit_column = "&\\multicolumn{1}{c|}{\\textbf{($\\mu$seconds)}}"
   config_column = "\\multirow{3}{*}{\\textbf{Benchmark}} &\\multicolumn{1}{c|}{\\textbf{Baseline}}"
   measurement_column = "&";
   for i in range(len(config_opts)):
     if config_opts[i] != 0:
      table_header =  table_header + "|rr"
      config_column = config_column + "& \\multicolumn{2}{c|}{\\textbf{"+ config_values[i] + "}}"
      unit_column = unit_column + "& \\multicolumn{2}{c|}{\\textbf{(\\%)}}"
      measurement_column = measurement_column + "&\\multicolumn{1}{c}{\\textbf{ovr.}}&\\multicolumn{1}{c|}{\\textbf{stddev}}"
   table_header = table_header + "}"
   config_column = config_column + "\\\\"
   unit_column =  unit_column + "\\\\"
   measurement_column = measurement_column + "\\\\"
   table_file.write(table_header+"\n")
   table_file.write(config_column+"\n")
   table_file.write(unit_column+"\n")
   table_file.write(measurement_column+"\n")
   table_file.write("\\hline"+"\n")

def generate_latex_bandwidth_table_header(table_file, config_opts):
   # Create main latex table header
   if enable_debug:
      print("Config options are: {}".format(config_opts))
   table_header = "\\begin{tabular}{l|r"
   unit_column = "&\\multicolumn{1}{c|}{\\textbf{(GB/s)}}"
   config_column = "\\multirow{3}{*}{\\textbf{Benchmark}} &\\multicolumn{1}{c|}{\\textbf{Baseline}}"
   measurement_column = "&";
   for i in range(len(config_opts)):
     if config_opts[i] != 0:
      table_header =  table_header + "|rr"
      config_column = config_column + "& \\multicolumn{2}{c|}{\\textbf{"+ config_values[i] + "}}"
      unit_column = unit_column + "& \\multicolumn{2}{c|}{\\textbf{(\\%)}}"
      measurement_column = measurement_column + "&\\multicolumn{1}{c}{\\textbf{ovr.}}&\\multicolumn{1}{c|}{\\textbf{stddev}}"
   table_header = table_header + "}"
   config_column = config_column + "\\\\"
   unit_column =  unit_column + "\\\\"
   measurement_column = measurement_column + "\\\\"
   table_file.write(table_header+"\n")
   table_file.write(config_column+"\n")
   table_file.write(unit_column+"\n")
   table_file.write(measurement_column+"\n")
   table_file.write("\\hline"+"\n")

def generate_latex_security_table_prologue(table_file):
    table_header = "\\begin{tabular}{c|r}"
    number_column = "Run & Reproductions" + "\\\\"
    table_file.write(table_header)
    table_file.write(number_column)

def generate_latex_security_table_epilogue(table_file):
    table_file.write("\\hline\n") 
    table_file.write("\\end{tabular}\n")     
 
 
def generate_latex_performance_table(benchmark, bench_results, stddev_results, bench_blueprint, table_file):
    result_lists = {}
    stddev_lists = {}
    baseline_results = []
    print("Plotting tables for {}...".format(benchmark))
    for bench_name, bench_values in bench_results.items():
        result_list = []
        stddev_list = []
        for b in bench_blueprint:
            result_list += [float(bench_values[b])]
            stddev_list += [float(stddev_results[bench_name][b])]
        result_lists[bench_name] = result_list
        stddev_lists[bench_name] =  stddev_list

    generate_latex_performance_table_header(table_file, get_config_opts(result_lists.keys()))

    # Filter out baseline from the results
    for target in result_lists.keys():
        if baseline_pattern in target:
           baseline_results = result_lists[target]
           result_lists.pop(target)
           stddev_lists.pop(target)
           break

    # Create baseline array to compute overheads
    base_arr = np.array(baseline_results)
    columns = {}
    geo_means = {}
    for bench_name, list_results in result_lists.items():
        ovr_arr = np.subtract(np.multiply(np.divide(np.array(list_results), base_arr), 100.0) , 100.0)
        var_arr = np.multiply(np.divide(np.array(stddev_lists[bench_name]), base_arr), 100.0)

        geo_means[bench_name] = (np.divide(np.array(list_results), base_arr).prod())**(1.0/len(base_arr))
        columns[bench_name] = {}
        columns[bench_name]["ovr"] = ovr_arr
        columns[bench_name]["var"] = var_arr
 
    i = 0
    for b in bench_blueprint:
        label_name = b
        if label_name in lmbench_simplified_names:
            label_name = lmbench_simplified_names[label_name]
        line = "\\textbf{{{}}}".format(label_name.replace("_","\\_"))
        line = "{}&\\textbf{{{}}}".format(line, round(base_arr[i], 2))
        for target in result_lists.keys():
            line = "{} &\\textbf{{{}\\%}}".format(line, round(columns[target]["ovr"][i],1))
            line = "{} &\\textbf{{$\pm$({}\\%)}}".format(line, round(columns[target]["var"][i],1))
        table_file.write("{}\\\\\n".format(line))
        i = i + 1
    line = "\\textbf{{{}}}&-".format("Geo mean.")
    for target in result_lists.keys():
        line = "{} &\\textbf{{{}\\%}}&-".format(line, round(((geo_means[target] - 1.0) * 100.0), 1))
    table_file.write("{}\\\\\n".format(line))  
    table_file.write("\\hline\n") 
    table_file.write("\\end{tabular}\n") 

def generate_latex_bandwidth_table(benchmark, bench_results, stddev_results, bench_blueprint, table_file):
    result_lists = {}
    stddev_lists = {}
    baseline_results = []
    print("Plotting tables for {}...".format(benchmark))
    for bench_name, bench_values in bench_results.items():
        result_list = []
        stddev_list = []
        for b in bench_blueprint:
            result_list += [float(bench_values[b])]
            stddev_list += [float(stddev_results[bench_name][b])]
        result_lists[bench_name] = result_list
        stddev_lists[bench_name] =  stddev_list

    generate_latex_bandwidth_table_header(table_file, get_config_opts(result_lists.keys()))

    for target in result_lists.keys():
        if baseline_pattern in target:
           baseline_results = result_lists[target]
           result_lists.pop(target)
           stddev_lists.pop(target)
           break

    base_arr = np.array(baseline_results)

    columns = {}
    geo_means = {}
    for bench_name, list_results in result_lists.items():
        ovr_arr = np.subtract(100.0, np.multiply(np.divide(np.array(list_results), base_arr), 100.0))
        var_arr = np.multiply(np.divide(np.array(stddev_lists[bench_name]), base_arr), 100.0)

        geo_means[bench_name] = (np.divide(np.array(list_results), base_arr).prod())**(1.0/len(base_arr))
        columns[bench_name] = {}
        columns[bench_name]["ovr"] = ovr_arr
        columns[bench_name]["var"] = var_arr
    
    i = 0
    for b in bench_blueprint:
        label_name = b
        if label_name in lmbench_simplified_names:
            label_name = lmbench_simplified_names[label_name]
        label_name = label_name.replace(" bandwidth", "").replace("AF_UNIX sock stream", "AF_UNIX").replace("File /var/tmp/XXX write", "File write").replace("Socket using localhost", "Socket bandwidth").replace("Memory", "Mem.")
        if label_name == "File write":
            base_arr[i] = base_arr[i]/1000
        line = "\\textbf{{{}}}".format(label_name.replace("_","\\_"))
        line = "{}&\\textbf{{{}}}".format(line, round(base_arr[i]/1000, 2))
        for target in result_lists.keys():
            line = "{} &\\textbf{{{}\\%}}".format(line, round(columns[target]["ovr"][i],1))
            line = "{} &\\textbf{{$\pm$({}\\%)}}".format(line, round(columns[target]["var"][i],1))
        table_file.write("{}\\\\\n".format(line))
        i = i + 1
    line = "\\textbf{{{}}}&-".format("Geo mean.")
    for target in result_lists.keys():
        line = "{} &\\textbf{{{}\\%}}&-".format(line, round(((1.0 - geo_means[target]) * 100.0), 1))
    table_file.write("{}\\\\\n".format(line))  
    table_file.write("\\hline\n") 
    table_file.write("\\end{tabular}\n")   

def generate_latex_security_table(security_results, table_file):
    i = 1
    for result in security_results:
        line = "{} & {}".format(i, result)
        table_file.write("{}\\\\\n".format(line))
        i = i + 1
    avg_arr = np.array(security_results)
    avg_val = np.average(avg_arr)
    line = "Average & {}".format(round(avg_val, 2))
    table_file.write("{}\\\\\n".format(line))


if __name__ == '__main__':
     for is_paper in output_configs:
      for benchmark in benchmark_suites:
         benchmark_dir =  benchmark.replace("_bandwidth", "")
         bench_dirs = select_benchmark_dirs(source_file_path+benchmark_dir, is_paper)
         if (bench_dirs == None):
            print("Run artifact to get local results for {}".format(benchmark))
            continue
            
         if (benchmark != "phoronix"):
             direction = None
             plot_column = target_result_column
         else:
             direction = aggregate_column(bench_dirs, "info")
             plot_column = "avg_rounded"
         bench_results = aggregate_numeric_results(bench_dirs, plot_column)
         stddev_results = aggregate_numeric_results(bench_dirs, "stddev")
         #if enable_debug:
         #   print("Ordered results {}".format(bench_results.keys()))
         if (benchmark == "lmbench"):
             with open("../tables/lmbench_performance_{}.tex".format(is_paper), "w") as table_file:
               generate_latex_performance_table(benchmark, bench_results, stddev_results, blueprints[benchmark], table_file)
         elif (benchmark == "lmbench_bandwidth"):
             with open("../tables/lmbench_bandwidth_{}.tex".format(is_paper), "w") as table_file:
               generate_latex_bandwidth_table(benchmark, bench_results, stddev_results, blueprints[benchmark], table_file)
         else:
             plot_normalized_barchart(benchmark, bench_results, stddev_results, blueprints[benchmark], direction, "../figs/{}_performance_{}.pdf".format(benchmark, is_paper))
         
     for configuration in ["baseline", "safefetch"]:
        with open("../tables/security_{}.tex".format(configuration), "w") as table_file:
            generate_latex_security_table_prologue(table_file)
            file_dir = select_security_dirs(security_file_path, configuration)  
            if (file_dir != None):
                security_results = aggregate_numeric_security_results(file_dir, "reproductions")
                generate_latex_security_table(security_results, table_file)
            generate_latex_security_table_epilogue(table_file)