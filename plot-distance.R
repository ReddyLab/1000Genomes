#!/usr/bin/Rscript --vanilla

EUR <- read.table("distance-splice-EUR.txt");
AMR <- read.table("distance-splice-AMR.txt");
AFR <- read.table("distance-splice-AFR.txt");
SAS <- read.table("distance-splice-SAS.txt");
EAS <- read.table("distance-splice-EAS.txt");
#EUR <- read.table("distance-broken-EUR.txt");
#AMR <- read.table("distance-broken-AMR.txt");
#AFR <- read.table("distance-broken-AFR.txt");
#SAS <- read.table("distance-broken-SAS.txt");
#EAS <- read.table("distance-broken-EAS.txt");
x <- "Non-reference alleles";
#y <- "Total LOF alleles";
y <- "Alleles with splicing differences";
minX <- 5654145;
maxX <- 6752602;
#minY <- 157;
#maxY <- 248;
minY <- 61;
maxY <- 131;
#outfile <- "distance-colors.pdf";
outfile <- "distance-splice-colors.pdf";

pdf(outfile);
plot(EUR,col="black",xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16);
points(AMR,col="red",xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16);
points(SAS,col="blue",xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16);
points(EAS,col="green",xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16);
points(AFR,col="orange",xlab=x,ylab=y,xlim=c(minX,maxX),ylim=c(minY,maxY),pch=16);
dev.off();



