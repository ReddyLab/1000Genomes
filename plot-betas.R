#!/usr/bin/Rscript --vanilla

infile <- "betas.txt"
c <- "black"
x <- "FPKM threshold"
y <- "Beta"
minX <- 0
maxX <- 20
minY <- 0
maxY <- 1
outfile <- "betas.pdf"
title <- "Beta as a function of FPKM threshold"

pdf(outfile);
data <- read.table(infile);
plot(data,col=c,xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16,
     main=title);
dev.off();



