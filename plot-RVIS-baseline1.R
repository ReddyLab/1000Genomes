#!/usr/bin/Rscript --vanilla

infile <- "/home/bmajoros/intolerance/RVIS/RVIS.txt";
outfile <- "RVIS-baseline1.pdf"
c <- rgb(0.1,0.1,0.1,1/4)
minX <- 0
maxX <- 100
resolution <- 10
xlabel <- "RVIS percentile"
ylabel <- "Number of genes"
title <- "Distribution of RVIS percentiles"

pdf(outfile);
data <- read.table(infile);
h <- hist(data$V3,breaks=seq(minX,maxX,resolution),col=rgb(0.1,0.1,0.1,1/4),main=title,xlab=xlabel,ylab=ylabel);
#plot(h,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,maxX),xlab=xlabel,ylab=ylabel,freq=F,main=title);
dev.off();



