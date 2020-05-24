# -*- coding: utf-8 -*-
"""
Description : 
    Le script permet la visualisation des données essentielles sous la forme 
    de graphique interprétable. Et de pourvoir ainsi mieux les comparer.
    
"""


import io,sys,os,glob,re
import matplotlib.pyplot as plt
import numpy as np



if len(sys.argv) != 2:
    print("Erreur sur les arguments")
    print("Usage : <fichier d'analyse>")
    exit(0)


period = "10"
oppnet = "ibrdtn"
def out_filename(name):
    return period + '_' + name + '_' + oppnet

class Global:
    def __init__(self):
        self.startTime = None
        self.duration = None
        self.activeNodes = None
        self.messageSent = None
        self.messagesReceived = None
    
    def getStartTime(self):
        return self.startTime
    def getDuration(self):
        return self.duration
    def getActiveNodes(self):
        return self.activeNodes
    def getMessageSent(self):
        return self.messageSent
    def getMessagesReceived(self):
        return self.messagesReceived
    
    def setStartTime(self,v):
        self.startTime = v
    def setDuration(self,v):
        self.duration = v
    def setActiveNodes(self,v):
        self.activeNodes = v
    def setMessageSent(self,v):
        self.messageSent = v
    def setMessagesReceived(self,v):
        self.messagesReceived = v


class Message:
    def __init__(self,messageId_,src_,dst_,sndStep_,rcvStep_,rcvDuration_):
        self.messageId = messageId_
        self.src = src_
        self.dst = dst_
        self.sndStep = sndStep_
        self.rcvStep = rcvStep_
        self.rcvDuration = rcvDuration_ 

    def getId(self):
        return self.id
    def getCrt(self):
        return self.src
    def getDst(self):
        return self.dst
    def getSndStep(self):
        return self.sndStep
    def getRcvStep(self):
        return self.rcvStep
    def getRcvDuration(self):
        return self.rcvDuration    
    

class Node:
    def __init__(self,nodeId_,duration_,sndEvts_,nbRcvTotal_,minNhb_,maxNhb_,outCon_,inCon_):
        self.nodeId = nodeId_
        self.duration = duration_
        self.sndEvts = sndEvts_
        self.nbRcvTotal = nbRcvTotal_
        self.minNhb = minNhb_
        self.maxNhb = maxNhb_
        self.outCon = outCon_
        self.inCon = inCon_
    
    def getNodeId(self):
        return self.nodeId
    def getDuration(self):
        return self.duration
    def getSndEvts(self):
        return self.sndEvts
    def getNbRcvTotal(self):
        return self.nbRcvTotal
    def getMinNhb(self):
        return self.minNhb
    def getMaxNhb(self):
        return self.maxNhb
    def getOutCon(self):
        return self.outCon
    def getInCon(self):
        return self.inCon
    
    
objGlobal = Global()
listNode = []
listMessage = []

        
def rmSpace(v):
    n = v.replace("\n","")
    return n[1:len(n)]

eventGlobal = False
eventNodes = False
eventMessages = False

countUnknownMessage = 0
#path="output.txt"
path=sys.argv[1]
with io.open(path, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True) as f:
    for line in f:
        #print(line.replace("\n",""))
        
        if "[Global]" in line:
            eventGlobal = True
            eventMessages = False
            eventNodes = False
            continue
        elif "[Nodes]" in line:
            eventNodes = True
            eventGlobal = False
            eventMessages = False
            continue
        elif "[Messages]" in line:
            eventMessages = True
            eventGlobal = False
            eventNodes = False
            continue
        
        if eventGlobal:
            if "start time" in line:
                objGlobal.setStartTime(rmSpace(line.split(":")[1]))
            elif "duration (s)" in line:
                objGlobal.setDuration(rmSpace(line.split(":")[1]))
            elif "active nodes" in line:
                objGlobal.setActiveNodes(rmSpace(line.split(":")[1]))
            elif "messages sent" in line:
                objGlobal.setMessageSent(rmSpace(line.split(":")[1]))
            elif "messages received" in line:
                objGlobal.setMessagesReceived(rmSpace(line.split(":")[1]))
            
        elif eventNodes:
            #print(line.replace("\n",""))
            if not "NodeId" in line:
                argOfLine = re.sub("[ ]{2,}",",",line.replace("\n","")).split(",")
                #print(len(argOfLine))
                if len(argOfLine) == 12 or len(argOfLine) == 9:
                    #print(argOfLine)
                    newObjNode = Node(argOfLine[1],argOfLine[2],argOfLine[3],argOfLine[4],argOfLine[5],argOfLine[6],argOfLine[7],argOfLine[8])
                    listNode.append(newObjNode)
                
        elif eventMessages:
            if "unknown" in line:
                countUnknownMessage+=1
                continue
            elif "-1" in line:
                countUnknownMessage+=1
                continue
            elif not "(" in line and not ")" in line:
                argOfLine = re.sub("[ ]{2,}",",",line.replace("\n","")).split(",")
                #print(len(argOfLine))
                if len(argOfLine) == 9:
                    newObjMessage = Message(argOfLine[1],argOfLine[2],argOfLine[3],argOfLine[4],argOfLine[5],argOfLine[6])
                    listMessage.append(newObjMessage)


print(len(listNode))
print(len(listMessage))
print("Unknown Message : "+str(countUnknownMessage))

s=0
c=0
p=0
for i in listNode:
    t=i.getNbRcvTotal().split("/")
    p+=int(t[1])-int(t[0])
    
for i in listMessage:
   c+=1
   s+=int(i.getRcvDuration())
   
print(s)
print(c)
print("------------------------")
print("La durée moyenne de réception est de "+str(int(s/c)) + " secondes ("+str(s/c)+")" )
print("Le nombre de messages non reçu est de "+str(p))
print("------------------------")




# def graphBar(size,barWidth,bars1,r1,listText,label,barColor,legende):
#     t,xl,yl = legende
#     plt.figure(figsize=size)
#     plt.barh(r1, bars1, height = barWidth, color = barColor)
#     plt.legend() 
#     plt.yticks([r + barWidth for r in range(len(r1))], listText)
    
#     for i in range(len(r1)):
#         plt.text(y = r1[i]-0.2 , x = bars1[i]+0.5, s = label[i], size = 10)
    
#     plt.subplots_adjust(bottom= 0.2, top = 0.98)
#     plt.title(t)
#     plt.xlabel(xl)
#     plt.ylabel(yl)
#     plt.tight_layout()
#     plt.savefig(legende[0])
#     # plt.show()


def graphBar1(size,barWidth,bars1,r1,listText,barColor,label,legende,boolean, filename):
    t,xl,yl = legende
    plt.figure(figsize=size)
    plt.bar(r1, bars1, width = barWidth, color = barColor)
    plt.legend()
    plt.xticks([r + barWidth for r in range(len(r1))],listText, rotation=0)
    
    for i in range(len(r1)):
        plt.text(x = r1[i]-0.2 , y = bars1[i]+1, s = label[i], size = 10)
    plt.subplots_adjust(bottom= 0.2, top = 0.98)
    plt.title(t)
    plt.xlabel(xl)
    plt.ylabel(yl)
    plt.tight_layout()
    if boolean == True:
        plt.ylim(0,105)
    # plt.savefig(legende[0])
    plt.savefig(out_filename(filename))
    # plt.show()
    

def addToMap(key,value,m):
    if m.get(key) == None:
        m[key] = value
        return True
    else:
        if m.get(key) != value:
            return False
        else:
            return True

listNodeSort = []
for i in listNode:
    listNodeSort.append(i.getNodeId())
listNodeSort.sort()



listGraph1 = {}
for i in listNodeSort:
    count = 0
    countSum = 0
    for j in listMessage:
        if j.getDst() == i:
            count+=1
            countSum+=int(j.getRcvDuration())
    addToMap(i,countSum/count,listGraph1)    
        
xx = list(listGraph1.keys())
yy = list(listGraph1.values())

plt.figure(figsize=(10,5))
u, ind = np.unique(xx, return_inverse=True)
plt.plot(ind, yy)
plt.scatter(ind, yy)
plt.xticks(range(len(u)), u)
plt.ylim([0,max(yy)+10])
plt.xlabel("Node")
plt.ylabel("Average time (s)") # Durée moyenne
plt.title("Average node reception time") # Durée moyenne de réception des noeuds
plt.grid()
plt.savefig(out_filename('avg_rcv_duration'))
# plt.show()

listGraph2 = {}
for i in listNodeSort:
    count = 0
    countSum = 0
    for j in listMessage:
        if j.getCrt() == i:
            count+=1
            countSum+=int(j.getRcvDuration())
    addToMap(i,countSum/count,listGraph2)    
        
xx = list(listGraph2.keys())
yy = list(listGraph2.values())


plt.figure(figsize=(10,5))
u, ind = np.unique(xx, return_inverse=True)
plt.plot(ind, yy)
plt.scatter(ind, yy)
plt.xticks(range(len(u)), u)
plt.ylim([0,max(yy)+10])
plt.xlabel("Node") # Noeud Source
plt.ylabel("Average time (s)") # Durée moyenne
plt.title("Average sending time of each node") # Durée moyenne d'envoi de chaque noeud
plt.grid()
plt.savefig(out_filename('avg_snd_duration')) # Durée moyenne d'envoi de chaque noeud
# plt.show()



listGraph3 = {}

for i in listNodeSort:
    for j in listNode:
        if i == j.getNodeId():
            addToMap(i,int(j.getDuration()),listGraph3)
            
xx = list(listGraph3.keys())
yy = list(listGraph3.values())
graphBar1((10,5),0.9,yy,[1,2,3,4,5,6,7,8,9,10],listNodeSort,"lightskyblue",yy,("Node activity duration","Node","Activity duration (s)"),False, 'activity_duration') # "Durée d'activité de chaque noeud","Noeud","Durée d'activité"



listGraph4 = {}
listGraph5 = {}
for i in listNodeSort:
    for j in listNode:
        if i == j.getNodeId():
            addToMap(i,int(j.getOutCon()),listGraph4)
            addToMap(i,int(j.getInCon()),listGraph5)
            
xx = list(listGraph4.keys())
yy1 = list(listGraph4.values())
yy2 = list(listGraph5.values())

plt.figure(figsize=(10,5))
barWidth = 0.9
bars1 = yy1
bars2 = yy2
r1 = [1,4,7,10,13,16,19,22,25,28]
r2 = [2,5,8,11,14,17,20,23,26,29]
plt.bar(r1, bars1, width = barWidth, color ="dodgerblue", label='out')
plt.bar(r2, bars2, width = barWidth, color ="orange", label='in')
plt.legend()
plt.xticks([r*3 + 0.5 + barWidth for r in range(10)],xx)
label = ['n = 6', 'n = 25', 'n = 13']
plt.subplots_adjust(bottom= 0.2, top = 0.98)
plt.xlabel("Node") # Noeud
plt.ylabel("Nombre de connexion initiée")
plt.title("Number of in/out connections") # Nombre de connexions d'entrées et de sorties initiées par chaque noeud
plt.tight_layout()
plt.savefig(out_filename('nb_in_out_con')) # Nombre de connexions d'entrées et de sorties initiées par chaque noeud
# plt.show()



listGraph6 = {}

for i in listNodeSort:
    for j in listNode:
        if i == j.getNodeId():
            addToMap(i,j.getNbRcvTotal(),listGraph6)
xx = list(listGraph6.keys())
yy = []

for i in list(listGraph6.values()):
    t = i.split("/")
    yy.append(int((int(t[0])/int(t[1]))*100))

graphBar1((10,5),0.9,yy,[1,2,3,4,5,6,7,8,9,10],listNodeSort,"slategray",yy,("Messages received by the nodes","Node","Messages received (%)"),True, 'msg_rcv') # "Pourcentage des messages reçus pour chaque noeud","Noeud","Pourcentage des messages reçus"



listGraph7 = {}
listGraph8 = {}

for i in listNodeSort:
    for j in listNode:
        if i == j.getNodeId():
            addToMap(i,int(j.getMinNhb()),listGraph7)
            addToMap(i,int(j.getMaxNhb()),listGraph8)

xx = list(listGraph7.keys())
yy1 = list(listGraph7.values())
yy2 = list(listGraph8.values())



u, ind = np.unique(xx, return_inverse=True)
plt.figure(figsize=(10,5))
plt.plot(ind, yy1,label="min") # Nombre minimum
plt.plot(ind, yy2,label="max") # Nombre maximum
plt.scatter(ind, yy1)
plt.scatter(ind, yy2)
plt.xticks(range(len(u)), u)
plt.ylim([0,max(max(yy1),max(yy2))+1])
plt.xlabel("Node") #
plt.ylabel("Number of neighbors") # Nombre de voisin
plt.title("Number of neighbors by node") # Nombre de voisin par noeud
plt.legend()
plt.grid()
plt.savefig(out_filename('nb_neighbors')) # "Nombre de voisin par noeud"
# plt.show()












