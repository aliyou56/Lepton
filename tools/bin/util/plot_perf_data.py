import matplotlib.pyplot as plt
import os
import csv
import sys

filename = sys.argv[1]
dirname = os.path.dirname(filename)

time = []
cpu = []
mem = []

# filename="/home/aliyou/Desktop/S2/projet_tutore/platform/lepton/scenario/adhocnet/result/adtn/cleaned-performance.txt"

with open(filename, 'r') as csvfile:
    plots = csv.reader(csvfile, delimiter=' ')
    #To skip the first line (the header)
    next(plots)
    for row in plots:
        time.append(float(row[0]))
        cpu.append(float(row[1]))
        mem.append(float(row[2]))

fig1 = plt.figure()
plt.plot(time, cpu, label='ADTN')
plt.ylim([0, 100])
plt.ylabel("CPU usage (%)")
plt.xlabel("Time (en s)")
plt.title('ADTN vs IBRDTN performance')
plt.legend()
# plt.show()
fig1.savefig(dirname + '/cpu_usage')

fig2 = plt.figure()
plt.plot(time, mem, label='ADTN')
plt.ylim([0, 100])
plt.ylabel("Memory usage (%)")
plt.xlabel("Time (en s)")
plt.title('ADTN vs IBRDTN performance')
plt.legend()
# plt.show()
fig2.savefig(dirname + '/mem_usage')