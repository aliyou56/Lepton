from dgs import header
from sys import argv
output=open(argv[1],"w")
output.write(header())
output.close()