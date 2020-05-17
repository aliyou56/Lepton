# -*- coding: utf-8 -*-

"""
Description: Le script permet de transformer les données des journaux de logs des nœuds, pour 
             extraire uniquement les informations pertinentes. Par la suite, les nouvelles 
             données seront utilisées dans le journal de l'analyseur.

             Arguments requis:
                 - Le dossier des nœuds IBRDTN
"""

import io,sys,os,glob,re

if len(sys.argv) != 2:
    print("Argument error")
    print("Usage: <folder of IBRDTN nodes>")
    exit(1)

def addToMap(key,value,m):
    if m.get(key) == None:
        m[key] = value
        return True
    else:
        if m.get(key) != value:
            #print("Error : Id_MSG="+key+" is already in the map with an other value="+value+", the actual value is "+m.get(key))
            return False
        else:
            return True

def addToMapOject(key,value,m):
    if m.get(key) == None:
        m[key] = value
        return True
    else:
        if m.get(key).getCrt() != value.getCrt() or m.get(key).getDst() != value.getDst():
            #print("Error : objet")
            return False
        else:
            return True

def getToMap(key,m):
    if m.get(key) != None:
        return m.get(key)
    else:
        #print("Error : The hey="+key+" is not find")
        return "unknown_"+key

def monthNameToNumber(monthName):
    switcher = {
        "JAN": "01",
        "FEB": "02",
        "MAR": "03",
        "APR": "04",
        "MAY": "05",
        "JUN": "06",
        "JUL": "07",
        "AUG": "08",
        "SEP": "09",
        "OCT": "10",
        "NOV": "11",
        "DEC": "12",
    }
    return switcher.get(monthName.upper(),"unknown") 

def makeGoodDate(monthName,dayNumber,hour,year):
    return year+"-"+monthNameToNumber(monthName)+"-"+dayNumber+" "+hour

"""
    Message : 
        - Id of message
        - Creator
        - Receiver
"""
class Message:
    def __init__(self,id_,crt_,dst_):
        self.id = id_
        self.crt = crt_
        self.dst = dst_

    def getId(self):
        return self.id
    def getCrt(self):
        return self.crt
    def getDst(self):
        return self.dst
    def setCrt(self,v):
        self.crt = v
    def setDst(self,v):
        self.dst = v
    def printMessage(self):
        print("ID : "+self.id)
        print("Crt : "+self.crt)
        print("Dst : "+self.dst)
    


bundleEventbundle = []
errorCreator = []
errorBundle = []
erreurV = []

mapIdMsg_creator = {}
mapIdMsg_recipient = {}
mapOfBundleEvent_IdMesg_creator_dst = {}

countBundleCoreTotal = 0
countBundleEventTotal = 0
countW1 = 0
countW2 = 0


path = sys.argv[1]

for i in os.listdir(path):
    #print(i)
    for idNode in glob.glob(path+i+os.path.sep+"*.log"):
        #print(idNode)   
        fullPath=idNode
        #print(fullPath)
        with io.open(fullPath, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True) as f:
            for line in f:
                #print(line.replace("\n",""))
                if "BundleCore: Bundle received" in line:
                    bundleEventbundle.append(line)
                    if "(local)" in line:
                        if not "routing" in line:
                            countBundleCoreTotal+=1
                            #print(line)
                            argOfLine = line.split(" ")
                            #print(argOfLine)
                            
                            idMsg = argOfLine[9].replace("[","").replace("]","")
                            #print(idMsg)

                            idNodeOfLine = argOfLine[10].replace("dtn://","").split("/")
                            #print(idNodeOfLine)
                            
                            if idNodeOfLine[1] != "":
                                #print(idNodeOfLine[0])
                                #print(i)
                            
                                if i == idNodeOfLine[0]:
                                    #print(line.replace("\n",""))
                            
                                    if addToMap(idNodeOfLine[1],i,mapIdMsg_creator) == False:
                                        errorCreator.append(line)
                                    #else:
                                        #print("yes")
                                    
                                else:
                                    print("Error : Is not the good node")
                            else:
                                print("Error : Indentification not found") 
                    
                elif "BundleEvent: bundle" in line:
                    if "delivered" in line:
                        if not "routing" in line:
                            countBundleEventTotal+=1
                            #print(line.replace("\n",""))
                            argOfLine = line.split(" ")
                            #print(argOfLine)
                            tab = argOfLine[9].replace("dtn://","").split("/")
                            #print(tab)
                            idMsg = tab[1]
                            #print(idMsg)
                            crt = tab[0]
                            #print(crt)
                            if crt == "" or idMsg == "":
                                print("Erreur : FATAL")
                            obj = Message(idMsg,crt,i)
                            #obj=crt+","+i
                            if addToMapOject(idMsg,obj,mapOfBundleEvent_IdMesg_creator_dst) == False:
                                errorBundle.append(line)

print("\nThe first analysis of the node files is finished :")             
print("countBundleCoreTotal : "+str(countBundleCoreTotal))
print("countBundleEventTotal : "+str(countBundleEventTotal))
print("Map creator : "+str(len(mapIdMsg_creator)))
print("Map receive : "+str(len(mapOfBundleEvent_IdMesg_creator_dst)))
print("Errors of creators : "+str(len(errorCreator)))
print("Errors of receives : "+str(len(errorBundle)))

for i in mapIdMsg_creator:
    #print(i)
    if "unknown_" in str(getToMap(i,mapOfBundleEvent_IdMesg_creator_dst)):
        #print("err")
        erreurV.append(i)
print("All messages not received : "+str(len(erreurV)))


print("Construction of folders and log files")
#print(path)
oldpath = ("//"+path+"//").split(os.path.sep)
#print(oldpath)
folder = ""
for i in oldpath:
    if i != "":
        folder=i
        break
#print("folder : "+folder)
newpath = folder+os.path.sep+"newLogNodesOf"+folder
#print(newpath)

if not os.path.exists(newpath):
    os.makedirs(newpath)

for i in os.listdir(path):
    #print(i)
    newpathNode = newpath+os.path.sep+i
    #print(newpathNode)
    if not os.path.exists(newpathNode):
        os.makedirs(newpathNode)
    newpathNodeFile = newpathNode+os.path.sep+"log.log"
    #print("newpathNodeFile : "+newpathNodeFile)
    newFile = open(newpathNodeFile,"w+")
    newFile.close()

print("Generation of new files of log")

pathNewLog = newpath
#print(pathNewLog)



for i in os.listdir(path):
    #print(i)
    pathNewLogNode = pathNewLog+os.path.sep+i+os.path.sep+"log.log"
    #print(pathNewLogNode)
    fileNode = open(pathNewLogNode,"a")

    for idNode in glob.glob(path+i+os.path.sep+"*.log"):
        #print(idNode)   
        fullPath=idNode
        with io.open(fullPath, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True) as f:
            for line in f:
                if "BundleCore: Bundle received" in line:
                    bundleEventbundle.append(line)
                    if "(local)" in line:
                        if not "routing" in line:
                            countW1+=1
                            #print(line.replace("\n",""))
                            tabOfArg = line.split(" ")
                            #print(tabOfArg)
                            dayNumber = tabOfArg[2]
                            if len(dayNumber) == 1:
                                dayNumber = "0"+dayNumber
                            date = makeGoodDate(tabOfArg[1],dayNumber,tabOfArg[3],tabOfArg[4])
                            info = "CREATE"
                            crt = ""
                            dst = ""
                            tabOfArgNameAndId = tabOfArg[10].replace("dtn://","").split("/")
                            #print(tabOfArgNameAndId)
                            #print("i : "+i)
                            if tabOfArgNameAndId[0] == i:
                                crt = i
                            else:
                                print("Erreur de creation de message")
                            idM = tabOfArgNameAndId[1]
                            #print(idM)
                            b = True
                            for j in erreurV:
                                if j == idM:
                                    b = False
                                    break
                            if b == False:
                                dst = "unknown"
                            else:
                                obj = getToMap(idM,mapOfBundleEvent_IdMesg_creator_dst)
                                if obj.getCrt() == i:
                                    dst = obj.getDst()
                                else:
                                    print("Erreur de correspondance de creator")
                                    dst = "unknown"
                            #print(date)
                            #print(idM)
                            #print(crt)
                            #print(dst)
                            newLineToWrite = info+","+date+","+idM+","+crt+","+dst+"\n"
                            #print(newLineToWrite)
                            fileNode.write(newLineToWrite)

                elif "BundleEvent: bundle" in line:
                    if "delivered" in line:
                        if not "routing" in line:
                            countW2+=1
                            tabOfArg = line.split(" ")
                            #print(tabOfArg)
                            dayNumber = tabOfArg[2]
                            if len(dayNumber) == 1:
                                dayNumber = "0"+dayNumber
                            date = makeGoodDate(tabOfArg[1],dayNumber,tabOfArg[3],tabOfArg[4])
                            info = "RECEIVE"
                            dst = i
                            tabOfArgNameAndId = tabOfArg[9].replace("dtn://","").split("/")
                            #print(tabOfArgNameAndId)
                            idM = tabOfArgNameAndId[1]
                            crt = tabOfArgNameAndId[0]
                            if getToMap(idM,mapIdMsg_creator) != crt:
                                print("Erreur le message n'existe pas")
                            #print(info)
                            #print(date)
                            #print(idM)
                            #print(crt)
                            #print(dst)
                            newLineToWrite = info+","+date+","+idM+","+crt+","+dst+"\n"
                            #print(newLineToWrite)
                            fileNode.write(newLineToWrite)

    fileNode.close()


if countBundleCoreTotal == countW1 and countBundleEventTotal == countW2:
    print("\nSuccessfully finished\n")
else:
    print("\nFinished but there are errors\n")

exit(0)