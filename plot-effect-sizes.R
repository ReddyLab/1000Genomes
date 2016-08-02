#!/usr/bin/Rscript --vanilla

infile <- "effect-sizes-log.txt";
c <- rgb(0.1,0.1,0.1,1/4);
minX <- -12;
maxX <- 2;
nbreaks <- 50;
xlabel <- "Log2 effect size"
outfile <- "effect-sizes.pdf"

pdf(outfile);
data <- read.table(infile);
if(nbreaks>0) {
  hist(data$V1,xlim=c(minX,maxX),xlab=xlabel,col=c,breaks=nbreaks);
} else {
  hist(data$V1,xlim=c(minX,maxX),xlab=xlabel,col=c);
}
dev.off();


