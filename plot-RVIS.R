#!/usr/bin/Rscript --vanilla

args <- commandArgs(TRUE)
if(length(args)!=7) {
  cat("usage: infile.txt color min-x max-x num-bins x-label outfile.pdf\n");
  q(status=1)
}
infile <- args[1];
c <- args[2];
minX <- as.numeric(args[3]);
maxX <- as.numeric(args[4]);
nbreaks <- as.numeric(args[5]);
xlabel <- args[6];
outfile <- args[7];

pdf(outfile);
data <- read.table(infile);
if(nbreaks>0) {
  hist(data$V1,xlim=c(minX,maxX),xlab=xlabel,col=c,breaks=nbreaks);
} else {
  hist(data$V1,xlim=c(minX,maxX),xlab=xlabel,col=c);
}
dev.off();



