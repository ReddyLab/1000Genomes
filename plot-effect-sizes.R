#!/usr/bin/Rscript --vanilla

infile <- "effect-sizes-log.txt";
c <- rgb(0.1,0.1,0.1,1/4);
minX <- -12;
maxX <- 2;
nbreaks <- 50;
xlabel <- "Log2 effect size"
outfile <- "effect-sizes-density.pdf"
title <- "Distribution of log2 effect size"

pdf(outfile);
data <- read.table(infile);
d <- density(data$V1);
plot(d,xlim=c(minX,maxX),xlab=xlabel,main=title);
abline(v=-1,lty=2)
dev.off();



