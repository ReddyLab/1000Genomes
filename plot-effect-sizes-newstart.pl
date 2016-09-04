#!/bin/env Rscript

#  #!/usr/bin/Rscript --vanilla
#  #!/data/reddylab/software/anaconda/bin/Rscript --vanilla

infile0 <- "effect-sizes-log-newstart-homo.txt";
infile1 <- "effect-sizes-log-newstart-het.txt";
#infile2 <- "effect-sizes-log.txt";
c <- rgb(0.1,0.1,0.1,1/4);
minX <- -6;
maxX <- 2;
xlabel <- "Log2 effect size"
outfile <- "effect-sizes-newstart-density.pdf"
title <- "Distribution of log2 effect size"

pdf(outfile);
data0 <- read.table(infile0);
data1 <- read.table(infile1);
#data2 <- read.table(infile2);
d0 <- density(data0$V1);
d1 <- density(data1$V1);
#d2 <- density(data2$V1);
plot(d1,xlim=c(minX,maxX),xlab=xlabel,main=title,col="blue");
lines(d0,col="red");
#lines(d2,col="black");
abline(v=-0.4,lty=2)
abline(v=-1,lty=1)
dev.off();



