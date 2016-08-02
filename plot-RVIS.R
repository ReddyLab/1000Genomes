#!/usr/bin/Rscript --vanilla

args <- commandArgs(TRUE)
if(length(args)!=7) {
  cat("usage: infile.txt color min-x max-x num-bins x-label outfile.pdf\n");
  q(status=1)
}
infile <- "broken-rvis-percentile.txt"
c <- rgb(0.1,0.1,0.1,1/4)
minX <- 0
maxX <- 10
nbreaks <- 10
xlabel <- "RVIS percentile"
outfile <- "RVIS.pdf"
title <- "Distribution of RVIS percentiles"

pdf(outfile);
data <- read.table(infile);
if(nbreaks>0) {
  hist(data$V1,xlim=c(minX,maxX),xlab=xlabel,col=c,breaks=nbreaks,main=title);
} else {
  hist(data$V1,xlim=c(minX,maxX),xlab=xlabel,col=c,main=title);
}
dev.off();



