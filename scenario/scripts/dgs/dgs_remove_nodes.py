import sys
print(sys.argv)
n = int(sys.argv[1])
accepted=[]
for line in sys.stdin:
    tok = line.split(" ")
    if (tok[0] == "an"):
        if len(accepted) < n :
            accepted.append(tok[1])
            sys.stdout.write(line)
    elif (tok[0] == "cn") and (tok[1] in accepted):
        sys.stdout.write(line)
    elif (not tok[0]=="cn"):
        sys.stdout.write(line)