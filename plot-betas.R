#!/usr/bin/Rscript --vanilla

outfile <- "betas-transformed.pdf"
infile <- "betas.txt"
c <- "black"
x <- "FPKM threshold"
y <- "Mean FPKM proportion"
title <- "Reduction in expression as a function of FPKM threshold"
minX <- 0
maxX <- 15
minY <- 0
maxY <- 1

pdf(outfile);
data <- read.table(infile);
data$V2 <- 0.5 ^ (2*data$V2);
#plot(data,col=c,xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16,main=title);
plot(data,col=c,xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16,
     main=title);
dev.off();



