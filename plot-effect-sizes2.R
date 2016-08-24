#!/usr/bin/Rscript --vanilla

infile0 <- "effect-sizes-log0.txt";
infile1 <- "effect-sizes-log1.txt";
c <- rgb(0.1,0.1,0.1,1/4);
minX <- -12;
maxX <- 2;
nbreaks <- 50;
xlabel <- "Log2 effect size"
outfile <- "effect-sizes-density.pdf"
title <- "Distribution of log2 effect size"

pdf(outfile);
data0 <- read.table(infile0);
data1 <- read.table(infile1);
d0 <- density(data0$V1);
d1 <- density(data1$V1);
plot(d0,xlim=c(minX,maxX),xlab=xlabel,main=title);
lines(d1);
abline(v=-1,lty=2)
dev.off();



