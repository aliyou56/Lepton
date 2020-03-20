import sys

start = 1000 # Start is assumed to be 1000
duration = sys.argv[1]

def nodeToHist(line):
    tok = line.split(" ")
    return " ".join([str(start),str(start+int(duration)),duration,tok[1]])+"\n"

for line in sys.stdin:
    sys.stdout.write(nodeToHist(line))



