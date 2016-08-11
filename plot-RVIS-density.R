#!/usr/bin/Rscript --vanilla

#infile <- "/home/bmajoros/intolerance/RVIS/RVIS.txt";
#infile <- "broken-rvis-percentile.txt"
infile <- "broken-rvis-percentile.txt"
#outfile <- "RVIS.pdf"
outfile <- "RVIS-density.pdf"
#outfile <- "RVIS10.pdf"
minX <- 0
maxX <- 100
resolution <- 10
xlabel <- "RVIS percentile"
ylabel <- "Number of genes"
title <- "Variant intolerance percentiles for inactivated genes"

pdf(outfile);
data <- read.table(infile);
h <- density(data$V2);
plot(h,main=title,xlab=xlabel,ylab=ylabel);
#plot(h,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,maxX),xlab=xlabel,ylab=ylabel,freq=F,main=title);
dev.off();



