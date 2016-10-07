#!/bin/env Rscript

dir <- "/home/bmajoros/hapmix/data-prep"
chroms <- list("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8",
               "chr9","chr10","chr11","chr12","chr13","chr14","chr15",
               "chr16","chr17","chr18","chr19","chr20","chr21","chr22")

for(chr in chroms) {
   hapmapFile <- paste("hapmap/genetic_map_GRCh37_",chr,".txt",sep="")
   hapmap <- read.table(hapmapFile,header=T)
   thousandFile <- paste("centimorgans/",chr,".pos",sep="")
   thousand <- read.table(thousandFile,header=F)
   interpolated <- approx(x=hapmap[[2]],y=hapmap[[4]],xout=thousand[[1]])
   interpolated$variant <- thousand[[2]]
   outputFile <- paste(chr,".interpolated",sep="")
   write.table(interpolated,outputFile,col.names=F,row.names=F)
}


