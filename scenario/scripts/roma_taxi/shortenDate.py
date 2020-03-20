import sys

taxiLineTimeConvertion = lambda line :\
    ";".join((
        line.split(';')[0],
        line.split(';')[1].split('.')[0].split('+')[0],
        *line.split(';')[2:]))

for line in sys.stdin:
    sys.stdout.write(taxiLineTimeConvertion(line))