import sys
import numpy as np

variance =  lambda x, y: float(x / y)
def compute_results(data):
    np_data = np.array(data)
    avg = np.mean(np_data)
    med = np.median(np_data)
    stddev = np.std(np_data)
    low = np.amin(np_data)
    high = np.amax(np_data)
    var = 0
    if avg != 0:
       var = variance(stddev, avg)
    else:
       var = 0
    return avg, med, stddev, low, high, var

for line in sys.stdin:
    arr = line.strip("\n").split(",")[1:]
    arr[:] = [x if x != '' else '0' for x in arr]
    arr = list(map (float, arr))
    avg, med, stddev, low, high, var = compute_results(arr)
    print("{};{};{};{};{};{}".format(avg, med, stddev, low, high, var))
