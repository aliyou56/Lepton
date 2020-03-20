import sys
import fileinput
from datetime import datetime

dateToTick = lambda timeFormat : lambda startString :lambda timeString :\
    str(1000 + 1000*int((datetime.strptime(timeString,timeFormat)-datetime.strptime(startString,timeFormat)).total_seconds()))
taxiDateFormat = "%Y-%m-%d %H:%M:%S"

taxiDateToTick = None
f = lambda line : \
    ";".join((
        line.split(';')[0],
        taxiDateToTick(line.split(';')[1]),
        *line.split(';')[2:]
    ))

for line in fileinput.input():
    if fileinput.isfirstline() :
        taxiDateToTick = dateToTick(taxiDateFormat)(line.split(";")[1])
    sys.stdout.write(f(line))