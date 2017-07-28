#!/usr/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2017 William H. Majoros (martiandna@gmail.com).
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)
# The above imports should allow this program to run in both Python 2 and
# Python 3.  You might need to update your version of module "future".
import sys
import ProgramName
from SummaryStats import SummaryStats

def load(filename):
    rocs=[]
    roc=[]
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)==2):
                x=float(fields[0])
                y=float(fields[1])
                roc.insert(0,[x,y])
            elif(len(roc)>0):
                rocs.append(roc)
                roc=[]
    return rocs

def interpolateRocs(rocs,Xs):
    newRocs=[]
    for roc in rocs:
        newRocs.append(interpolateRoc(roc,Xs))
    return newRocs

def getXrange(delta):
    r=[]
    x=0.0
    while(x<1.0):
        r.append(x)
        x+=delta
    if(r[len(r)-1]<1.0): r.append(1.0)
    return r

def interpolateRoc(roc,Xs):
    newRoc=[]
    i=0
    for x in Xs:
        i=advance(roc,i,x)
        y=interpolate(roc,i,x)
        newRoc.append([x,y])
    return newRoc

def advance(roc,i,x):
    N=len(roc)
    while(i<N and roc[i][0]<x): i+=1
    #print("roc[i][0]=",roc[i][0])
    if(i>=N): raise Exception("advance()")
    if(roc[i][0]==x): return i
    if(roc[i][0]>x):
        if(i>0): return i-1
        raise Exception("advance() x="+str(x)+" i="+str(i)+" N="+str(N))
    return i

def interpolate(roc,i,x):
    thisPair=roc[i]
    (thisX,thisY)=thisPair
    if(thisX==x): return thisY
    if(i+1>=len(roc)): raise Exception("interpolate()")
    nextPair=roc[i+1]
    (nextX,nextY)=nextPair
    slope=(nextY-thisY)/(nextX-thisX)
    delta=x-thisX
    return thisY+slope*delta
    
def getYs(rocs,i):
    Ys=[]
    for roc in rocs:
        Ys.append(roc[i][1])
    return Ys

def averageRocs(rocs,Xs):
    N=len(Xs)
    for i in range(N):
        x=Xs[i]
        Ys=getYs(rocs,i)
        (mean,SD,min,max)=SummaryStats.summaryStats(Ys)
        print(x,mean,mean-SD,mean+SD,sep="\t")

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <infile> <resolution>\n")
(infile,delta)=sys.argv[1:]
delta=float(delta)

rocs=load(infile)
numRocs=len(rocs)
Xs=getXrange(delta)
rocs=interpolateRocs(rocs,Xs)
averageRocs(rocs,Xs)
    


