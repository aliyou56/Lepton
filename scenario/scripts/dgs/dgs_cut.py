import sys

startTime=0 if len(sys.argv) < 2 else int(sys.argv[1])
length=3600000 if len(sys.argv) < 3 else int(sys.argv[2]) # defaults to 1h
endTime=startTime+length

def t(line,currentTime):
    arr = line.split(" ")
    return int(arr[1]) if arr[0] == "st" else currentTime

def p(currentTime):
    return currentTime == 0 or (currentTime >= startTime and currentTime <= endTime)

currentTime=0
for line in sys.stdin:
    currentTime = t(line,currentTime)
    if p(currentTime):
        sys.stdout.write(line)