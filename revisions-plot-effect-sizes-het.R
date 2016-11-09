#!/usr/bin/env Rscript

infile <- "effect-sizes-log-het.fpkm3";
#infile <- "effect-sizes-log-het.fpkm1";

outfile <- "effect-sizes-density-het-fpkm3.pdf"
#outfile <- "effect-sizes-density-het-fpkm1.pdf"

#=====================================================
c <- rgb(0.1,0.1,0.1,1/4);
minX <- -7;
maxX <- 2;
nbreaks <- 50;
xlabel <- "Log2 effect size"
title <- "Distribution of log2 effect size"

pdf(outfile);
data <- read.table(infile);
d <- density(data$V1);
plot(d,xlim=c(minX,maxX),xlab=xlabel,main=title);
abline(v=-0.415,lty=2)
dev.off();



