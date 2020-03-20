import sys
import fileinput
sys.path.append('../dgs/')
from dgs import *


def f(line):
    arr = line.split(";")
    xy = arr[2].split("(")[1].split(")")[0].split(" ")

    timeChange = event(st)(arr[1])
    xUpdate = attribute("x",values=[xy[0]])
    yUpdate = attribute("y",values=[xy[1]])
    posUpdate = event(cn)(arr[0])(xUpdate,yUpdate)
    return timeChange + "\n" + posUpdate +"\n"

for line in fileinput.input():
    sys.stdout.write(f(line))