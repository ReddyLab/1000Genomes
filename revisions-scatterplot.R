#!/bin/env Rscript

#    #!/usr/bin/Rscript --vanilla

args <- commandArgs(TRUE)
if(length(args)!=9) {
  cat("usage: infile.txt color x-label y-label min-x max-x min-y max-y outfile.pdf\n");
  q(status=1)
}
infile <- args[1];
c <- args[2];
x <- args[3];
y <- args[4];
minX <- as.numeric(args[5]);
maxX <- as.numeric(args[6]);
minY <- as.numeric(args[7]);
maxY <- as.numeric(args[8]);
outfile <- args[9];

pdf(outfile);
data <- read.table(infile);
plot(data,col=c,xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16);
abline(a=0,b=1,lty=2)
dev.off();



