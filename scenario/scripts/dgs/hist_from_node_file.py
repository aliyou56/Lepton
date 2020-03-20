 
# first step          : 1000
# last step           : 3600000
# duration            : 3599000
# nb nodes            : 100
# max concurrent nodes: 100
#
# begin end duration node
# 1000 3600000 3599000 N047
# 1000 3600000 3599000 N033
# 1000 3600000 3599000 N008
# 1000 3600000 3599000 N015

import sys

start = 1000 # Start is assumed to be 1000
duration = sys.argv[1]

def nodeToHist(line):
    tok = line.split(" ")
    return " ".join([str(start),str(start+int(duration)),duration,tok[1]])+"\n"

for line in sys.stdin:
    sys.stdout.write(nodeToHist(line))



