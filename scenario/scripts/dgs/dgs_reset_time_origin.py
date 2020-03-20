import sys
offset=None
for line in sys.stdin:
    tok = line.split(" ")
    if tok[0] == "st":
        if not offset :
            offset = int(tok[1])
        newTime = int(tok[1]) - offset + 1000
        sys.stdout.write(" ".join([tok[0],str(newTime)])+"\n")
    else :
        sys.stdout.write(line)