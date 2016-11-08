#!/bin/env Rscript

args <- commandArgs(TRUE)
if(length(args)!=8) {
  cat("usage: infile.txt color min-x max-x num-bins x-label title outfile.pdf\n");
  q(status=1)
}
infile <- args[1];
c <- args[2];
minX <- as.numeric(args[3]);
maxX <- as.numeric(args[4]);
nbreaks <- as.numeric(args[5]);
xlabel <- args[6];
title <- args[7];
outfile <- args[8];

pdf(outfile);
par(mfrow=c(2,1))
data <- read.table(infile);
hist(data$V1,xlim=c(minX,maxX),xlab=xlabel,col=c,breaks=seq(0,maxX,1),
     main=title);
#barplot(data$V1,xlim=c(minX,maxX),xlab=xlabel,col=c,breaks=seq(0,45,1),
#     main=title);
dev.off();



