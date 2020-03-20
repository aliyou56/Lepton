from dgs import *
import sys
hist = {}

def p(id):
    return hist.get(id,False)

def f(line):
    return line.split(" ")[0] == "st"
    
for line in sys.stdin:
    id = line.split(" ")[1]
    if f(line) and not p(id):
        hist[id] = True
        sys.stdout.write(line)
    elif not f(line) :
        sys.stdout.write(line)