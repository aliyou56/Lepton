#!/usr/bin/env python3

# -*- coding: utf-8 -*-

"""
    Description : Script permettant de convertir les logs ibrdtns vers des logs adtns. (lepton.out)
    Ceci permet donc de passer par le même convertisseur de données pour pouvoir les comparer,
    avec le moins d'erreur possible.

@author: Alexandre
"""
import io
import sys

print(sys.argv)

if len(sys.argv) != 2:
    print("Erreur sur les arguments")
    print("Usage : <fichier_ibrdtn.out>")
    exit(0)



fichier = open(sys.argv[1]+"ToAdtn.out", "a")
#fichier = open("log_ibrdtn.out", "a")
with io.open(sys.argv[1], mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True) as f:
    for line in f:
        if "hub ibrdtn: << source=" in line:
            print("NON")
            continue
        elif "IPND_Beacon" in line:
            old=line.split(" ")
            new=""
            new+=old[0]+" "+old[1]+" "+old[2]+" "+old[3]
            new+=" > 	 Source: "
            
            dmisAndPort=old[5].split("/")[2].replace("\"","")
            
            dmisNb=dmisAndPort.split(",")[0]
            
            new+=dmisNb+"   Port: "
            port=""
            
            for i in dmisAndPort.split(",")[2]:
                if i.isdigit():
                    port+=i
            new+=port+"	IP: 127.0.0.1\n"
            
            fichier.write(new)
        else:
            fichier.write(line)
            
fichier.close()
print("Fini")
exit(0)
