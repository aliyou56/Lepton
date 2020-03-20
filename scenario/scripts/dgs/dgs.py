#%%
left="<"
right=">"
lineReturn = "\n"
space = " "

apply = lambda f : f()
default = lambda f=None : default(f()) if callable(f) else f

comment = lambda string : "#" + string
text = lambda *lines : lineReturn.join(map(default,lines))
line = lambda *strings,separator=space : \
    separator.join(
        filter(bool,
            map(str,
                map(default,strings))))
header = lambda magic="DGS004",name="null",steps=0,events=0 : text(
        line(magic),
        line(name,steps,events,lineReturn)
    )


attribute = lambda id,assign="=",sign="",values=[] : \
    line(sign,id,assign,*values,separator="")

#events
event = lambda eventType : eventType # just an identity function to make code readable

an = lambda id : lambda *attributes : \
    line("an",id,*attributes) # Add node
cn = lambda id : lambda *attributes : \
    line("cn",id,*attributes) # Change|Configure node
dn = lambda id : line("dn",id) # Delete node
ae = lambda idEdge,idNode1,idNode2,direction="" : lambda *attributes : \
    line("ae",idEdge,idNode1,direction,idNode2,*attributes) # Add edge
ce = lambda id : lambda *attributes : line("ce",id,*attributes) # Change|Configure edge
de = lambda id : line("de",id) # Delete edge
cg = lambda *attributes : line("cg",*attributes) # Change|Configure graph
st = lambda real : line("st",real) # Set step
cl = lambda : line("cl") # Clear graph


#DGS templates
simpleDGS = lambda *events : text(header(),*events)

# %%
