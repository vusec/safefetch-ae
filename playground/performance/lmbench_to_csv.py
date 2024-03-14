import os
import export_csv

root_dir = "./lmbench"
blueprint = [
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
    "TCP/IP connection cost to localhost",
    "AF_UNIX sock stream bandwidth",
    "Pipe bandwidth",
    "File /var/tmp/XXX write bandwidth",
    "Socket bandwidth using localhost",
    "\"read bandwidth",
    "\"read open2close bandwidth",
    "\"Mmap read bandwidth",
    "\"Mmap read open2close bandwidth",
    "\"libc bcopy unaligned",
    "\"libc bcopy aligned", 
    "Memory bzero bandwidth",
    "\"unrolled bcopy unaligned",
    "\"unrolled partial bcopy unaligned",
    "Memory read bandwidth",
    "Memory partial read bandwidth",
    "Memory write bandwidth",
    "Memory partial write bandwidth",
    "Memory partial read/write bandwidth"
]

bandwidth_blueprints = [
    "\"read bandwidth",
    "\"read open2close bandwidth",
    "\"Mmap read bandwidth",
    "\"Mmap read open2close bandwidth",
    "\"libc bcopy unaligned",
    "\"libc bcopy aligned", 
    "Memory bzero bandwidth",
    "\"unrolled bcopy unaligned",
    "\"unrolled partial bcopy unaligned",
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



multiline_blueprints = ["Socket bandwidth using localhost", "size=0k"]
multiline_position = { "Socket bandwidth using localhost" : 2 , "size=0k" : 1 }

def extract_val(k, data):
    parsing_multiline = False
    for l in data:
        if parsing_multiline:
            if l == "\n":
               return multiline_value;
            multiline_value =  [float(l.split(" ")[1].strip().split(" ")[0])]
        if k in l and k in bandwidth_blueprints[:-3]:
            parsing_multiline = True
            continue
             
        if k in l:
            return [float(l.split(":")[1].strip().split(" ")[0])]

extract_val_func = extract_val


# Loop over all the unique OSBench benchmarks that are found within the performance dir
for x in os.listdir(root_dir):
    bench_dir = root_dir + "/" + x

    # Ignore non-directory entries
    if not os.path.isdir(bench_dir):
        continue

    # Extract all the values for that benchmark and convert it to a dictionary
    dir_values = export_csv.extract_values(bench_dir, blueprint, extract_val_func)

    number_trials = len(dir_values[blueprint[0]])

    # Compute statistics and export the computed values to a csv file
    export_csv.export_to_csv(root_dir, bench_dir, number_trials, dir_values)
