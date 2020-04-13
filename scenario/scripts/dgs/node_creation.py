from dgs import *
import sys
import fileinput

hist = {}

def p(line):
    return line.split(" ")[0] == "cn"

def f(line):
    hist[line.split(" ")[1]] = line.split(" ")[2:]
    
for line in fileinput.input():
    if(p(line)):
        f(line)

for id in hist.keys():
    sys.stdout.write(event(an)(id)(*hist[id]))
