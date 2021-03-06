#!/usr/bin/env Rscript


#====

outfile <- "supp9-new.pdf"

pdf(outfile);
par(mfrow=c(2,1))

#====

infile1 <- "supported-skipping-blind.txt";
infile2 <- "supported-skipping-real.txt";
x <- "Proportion of exon-skipping isoforms supported by at least one spliced read";
y <- "Density"
data1 <- read.table(infile1);
data2 <- read.table(infile2);
h1 <- density(data1$V1,from=0);
h2 <- density(data2$V1,from=0);
min1 <- min(data1$V1); max1 <- max(data1$V1);
min2 <- min(data2$V1); max2 <- max(data2$V1);
minX <- min(min1,min2); maxX <- max(max1,max2);
plot(h1,col="blue",xlab=x,ylab=y,xlim=c(minX,maxX),lwd=2,main="");
lines(h2,col="red",lwd=2);
legend("topright",legend=c("Without hints from ICE","With hints from ICE"),
       lty=c(1,1),lwd=c(2,2),col=c("blue","red"));

#====
infile1 <- "sensitivity-histogram-skipping.txt";
infile2 <- "proposal-histogram-skipping.txt";
x <- "Proportion of exon-skipping isoforms assigned nonzero FPKM";
y <- "Density";
data1 <- read.table(infile1);
data2 <- read.table(infile2);
h1 <- density(data1$V1);
h2 <- density(data2$V1);
min1 <- min(data1$V1); max1 <- max(data1$V1);
min2 <- min(data2$V1); max2 <- max(data2$V1);
minX <- min(min1,min2); maxX <- max(max1,max2);
plot(h1,col="blue",xlim=c(minX,maxX),ylim=c(0,10),xlab=x,ylab=y,main="",lwd=2);
lines(h2,col="red",xlim=c(minX,maxX),lwd=2);
legend("topright",legend=c("Without hints from ICE","With hints from ICE"),
       lty=c(1,1),lwd=c(2,2),col=c("blue","red"));

#====

infile1 <- "supported-skipping-sim.txt";
infile2 <- "supported-skipping.txt";
x <- "Proportion of exon-skipping isoforms supported by at least one spliced read";
y <- "Density";
data1 <- read.table(infile1);
data2 <- read.table(infile2);
h1 <- density(data1$V1);
h2 <- density(data2$V1);
min1 <- min(data1$V1); max1 <- max(data1$V1);
min2 <- min(data2$V1); max2 <- max(data2$V1);
minX <- min(min1,min2); maxX <- max(max1,max2);
plot(h1,col="blue",xlim=c(minX,maxX),xlab=x,ylab=y,main="",lwd=2);
lines(h2,col="red",xlim=c(minX,maxX),lwd=2);
legend("topright",legend=c("Non-disrupted sites","Disrupted sites"),
       lty=c(1,1),lwd=c(2,2),col=c("blue","red"));

#====

#infile1 <- "random-readcounts.txt";
#infile2 <- "readcounts.txt";
infile1 <- "random-readcounts-pos.txt";
infile2 <- "readcounts-pos.txt";
x <- "Log10(reads per junction)";
y <- "Density";
data1 <- log10(read.table(infile1));
data2 <- log10(read.table(infile2));
min1 <- min(data1$V1); max1 <- max(data1$V1);
min2 <- min(data2$V1); max2 <- max(data2$V1);
minX <- min(min1,min2); maxX <- max(max1,max2);
h1 <- density(data1$V1);
h2 <- density(data2$V1);
plot(h1,col="blue",xlim=c(0,maxX),xlab=x,ylab=y,main="",lwd=2);
lines(h2,col="red",lwd=2);
legend("topright",legend=c("Simulated disrupted sites","True disrupted sites"),
       lty=c(1,1),lwd=c(2,2),col=c("blue","red"));

#===
dev.off();


