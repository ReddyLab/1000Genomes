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
from EssexParser import EssexParser
from EssexNode import EssexNode
from Interval import Interval
from Rex import Rex
rex=Rex()

THOUSAND="/home/bmajoros/1000G/assembly"
COMBINED=THOUSAND+"/combined"

def hasBrokenSite(root):
    statusNode=root.findDescendent("status")
    numElem=statusNode.numElements()
    for i in range(numElem):
        elem=statusNode.getIthElem(i)
        if(EssexNode.isaNode(elem)):
            tag=elem.getTag()
            if(tag=="broken-donor" or tag=="broken-acceptor"): return elem
    return None

def hasSplicingChanges(root):
    statusNode=root.findDescendent("status")
    numElem=statusNode.numElements()
    for i in range(numElem):
        elem=statusNode.getIthElem(i)
        if(EssexNode.isaNode(elem)): continue
        if(elem=="splicing-changes"): return True
    return False

def parseDenovo(geneID,hap,transID,transcriptNode,geneType,altID,strand,
                seqLen,score,fate):
    site=transcriptNode.findDescendent("denovo-site")
    if(not site): return
    siteType=site.getIthElem(0)
    sitePos=int(site.getIthElem(1))
    originalSitePos=sitePos
    if(strand=="-"): sitePos-=1
    siteInterval=Interval(sitePos,sitePos+2)
    variantsNode=\
        transcriptNode.pathQuery("transcript/variants/splice-site-variants")
    if(not variantsNode): return
    numVariants=variantsNode.numElements()
    for i in range(numVariants):
        variant=variantsNode.getIthElem(i)
        fields=variant.split(":")
        variantID=fields[0]
        variantPos=int(fields[3])
        altLen=len(fields[5])
        if(strand=="-"): variantPos=variantPos-altLen+1
        variantInterval=Interval(variantPos,variantPos+altLen)
        if(variantInterval.overlaps(siteInterval)):
            if(strand=="-"):
                if(siteType=="donor"): sitePos+=2
            else:
                if(siteType=="acceptor"): sitePos+=2
            print("denovo",siteType,geneID,hap,geneType,transID,altID,strand,
                  score,str(sitePos),str(seqLen),fate,variantID,
                  sep="\t")
            return
    #print("can't find: ",siteType,geneID,altID,strand,
    #      str(originalSitePos),str(sitePos),str(variantPos),
    #      str(seqLen),variantID,str(altLen),fields[4],fields[5],
    #      siteInterval,variantInterval)

def parseCryptic(geneID,hap,transID,transcriptNode,geneType,altID,strand,
                 seqLen,score,fate,root):
    crypticSite=transcriptNode.findDescendent("cryptic-site")
    if(not crypticSite): return
    siteType=crypticSite.getIthElem(0)
    crypticSitePos=int(crypticSite.getIthElem(1))
    brokenSite=root.findDescendent("broken-"+siteType)
    if(not brokenSite): exit(altID+" broken-site not found")
    if(not brokenSite): return
    brokenSitePos=int(brokenSite.getIthElem(0))
    if(strand=="-"):
        crypticSitePos-=1
        brokenSitePos-=1
    brokenSiteInterval=Interval(brokenSitePos,brokenSitePos+2)
    variantsNode=\
        root.pathQuery("reference-transcript/variants/splice-site-variants")
    if(not variantsNode): return
    numVariants=variantsNode.numElements()
    for i in range(numVariants):
        variant=variantsNode.getIthElem(i)
        fields=variant.split(":")
        variantID=fields[0]
        variantPos=int(fields[3])
        altLen=len(fields[5])
        if(strand=="-"): variantPos=variantPos-altLen+1
        variantInterval=Interval(variantPos,variantPos+altLen)
        if(variantInterval.overlaps(brokenSiteInterval)):
            if(strand=="-"):
                if(siteType=="donor"): crypticSitePos+=2
            else:
                if(siteType=="acceptor"): crypticSitePos+=2
            print("cryptic",siteType,geneID,hap,geneType,transID,altID,
                  strand,score,str(crypticSitePos),str(seqLen),fate,
                  variantID,sep="\t")
            return
    #print("can't find cryptic-site: ",siteType,geneID,altID,strand,
    #      str(crypticSitePos),str(variantPos),
    #      str(seqLen),variantID,str(altLen),fields[4],fields[5],
    #      siteInterval,variantInterval)

def parseSkipping(geneID,hap,transID,transcriptNode,geneType,altID,strand,
                  seqLen,score,fate):
    brokenSite=root.findDescendent("broken-donor")
    if(not brokenSite): brokenSite=root.findDescendent("broken-acceptor")
    if(not brokenSite): exit(altID+" broken-site not found")
    if(not brokenSite): return
    brokenSitePos=int(brokenSite.getIthElem(0))
    if(strand=="-"):
        brokenSitePos-=1
    brokenSiteInterval=Interval(brokenSitePos,brokenSitePos+2)
    variantsNode=\
        root.pathQuery("reference-transcript/variants/splice-site-variants")
    if(not variantsNode): return
    numVariants=variantsNode.numElements()
    for i in range(numVariants):
        variant=variantsNode.getIthElem(i)
        fields=variant.split(":")
        variantID=fields[0]
        variantPos=int(fields[3])
        altLen=len(fields[5])
        if(strand=="-"): variantPos=variantPos-altLen+1
        variantInterval=Interval(variantPos,variantPos+altLen)
        if(variantInterval.overlaps(brokenSiteInterval)):
            #if(strand=="-"):
            #    if(siteType=="donor"): crypticSitePos+=2
            #else:
            #    if(siteType=="acceptor"): crypticSitePos+=2
            print("skipping",".",geneID,hap,geneType,transID,altID,
                  strand,score,".",str(seqLen),fate,
                  variantID,sep="\t")
            return

def getFate(transcriptNode):
    fateNode=transcriptNode.findChild("fate")
    if(fateNode is None): return "none"
    numElements=fateNode.numElements()
    for i in range(numElements):
        elem=fateNode.getIthElem(i)
        if(EssexNode.isaNode(elem)):
            matchNode=fateNode.findDescendent("percent-match")
            if(matchNode):
                return "protein-differs\t"+matchNode.getIthElem(0)
        elif(elem=="identical-protein" or elem=="NMD"): return elem
    return "none"

def reportBroken(elem):
    s=""
    N=elem.numElements()
    for i in range(N-1): s+=elem.getIthElem(i)+"\t"
    s+=elem.getIthElem(N-1)
    return s

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <indiv> <hap>\n")
(indiv,hap)=sys.argv[1:]

brokenSeen=set()
infile=COMBINED+"/"+indiv+"/"+hap+".logreg.essex"
parser=EssexParser(infile)
while(True):
    root=parser.nextElem()
    if(not root): break
    if(not hasSplicingChanges(root)): continue
    #broken=hasBrokenSite(root)
    #if(broken is not None):
    #    print("broken\t"+reportBroken(broken))
    geneID=root.getAttribute("gene-ID")
    geneType=root.findChild("reference-transcript").getAttribute("type")
    transID=root.getAttribute("transcript-ID")
    seqLen=int(root.getAttribute("alt-length"))
    altStructuresNode=root.pathQuery("report/status/alternate-structures")
    mappedSpliceVariantsNode=\
        root.pathQuery("report/mapped-transcript/variants/splice-site-variants")
    if(mappedSpliceVariantsNode is not None):
        n=mappedSpliceVariantsNode.numElements()
        for i in range(n):
            child=mappedSpliceVariantsNode.getIthElem(i)
            fields=child.split(":")
            variant=fields[0]
            if(variant in brokenSeen): continue
            brokenSeen.add(variant)
            print("broken",variant,sep="\t")
    numAlts=altStructuresNode.numElements()
    for i in range(numAlts):
        transcriptNode=altStructuresNode.getIthElem(i)
        changeType=transcriptNode.getAttribute("structure-change")
        altID=transcriptNode.getAttribute("ID")
        strand=transcriptNode.getAttribute("strand")
        score=float(transcriptNode.getAttribute("score"))
        fate="none" if geneType=="noncoding" else getFate(transcriptNode)
        if(changeType=="denovo-site"):
            parseDenovo(geneID,hap,transID,transcriptNode,geneType,altID,
                        strand,seqLen,score,fate)
        elif(changeType=="cryptic-site"):
            parseCryptic(geneID,hap,transID,transcriptNode,geneType,altID,
                         strand,seqLen,score,fate,root)
        elif(changeType=="exon-skipping"):
            parseSkipping(geneID,hap,transID,transcriptNode,geneType,altID,
                          strand,seqLen,score,fate)
parser.close()




