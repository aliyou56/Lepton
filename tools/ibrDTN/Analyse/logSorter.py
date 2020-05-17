# -*- coding: utf-8 -*-

import io,sys


#print(sys.argv)

if len(sys.argv) != 2:
    print("Erreur sur les arguments")
    print("Usage : <fichier_de_noeud>")
    exit(0)

def recherche(path,nb):
    with io.open(path, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True) as f:
        for line in f:
            if choix[nb] in line:
                print(line.replace("\n",""))

choix = ["NativeDaemon","Configuration","BundleCore","TCPConvergenceLayer",
         "IPNDAgent","EpidemicRoutingExtension","GlobalEvent","NodeEvent",
         "BundleEvent","QueueBundleEvent","ConnectionEvent","NodeHandshakeEvent",
         "BundlePurgeEvent","TransferCompletedEvent","TransferAbortedEvent","RequeueBundleEvent"]


print("Les choix de tries possible :")
c=0
for i in choix:
    print(str(c)+" : "+i)
    c+=1
quitValue=c
print(str(quitValue)+" : quitter")
    

num = 0
while int(num) != quitValue :
    
    num = input("Entrez un choix de log (un nombre est attendu): ")
    if int(num) == quitValue:
        continue
    elif int(num) < 0 or int(num) > len(choix):
        print("Les choix de tries possible :")
        c=0
        for i in choix:
            print(str(c)+" : "+i)
            c+=1
        quitValue=c
        print(str(quitValue)+" : quitter")
        num = input("Choix impossible, veillez recommencer : ")
        continue
    else:
        print("LOG :")
        recherche(sys.argv[1],int(num))

exit(0)