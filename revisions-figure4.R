#!/usr/bin/env Rscript

int.hist = function(x,ylab="Frequency",...) {
    barplot(table(factor(x,levels=min(x):max(x))),space=0,xaxt="n",ylab=ylab,...);axis(1)
}

#====

outfile <- "figure4-rev.pdf"

pdf(outfile);
par(mfrow=c(3,1))

infile <- "alt-struct-counts.txt";
x <- "Number of alternate structures predicted";
y <- "Frequency"
data <- read.table(infile);
h1 <- int.hist(data$V1,col="white",xlab=x,ylab=y);
minX <- min(data$V1); maxX <- max(data$V1);
#plot(h1,xlab=x,ylab=y,xlim=c(minX,maxX),main="");

#====

resolution <- 0.01;
infile1 <- "supported-cryptic-blind.txt-rev3";
infile2 <- "supported-cryptic2.txt-rev3";
x <- "Proportion of cryptic-site isoforms supported by at least three spliced reads";
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
infile1 <- "sensitivity-histogram-cryptic.txt-rev";
infile2 <- "proposal-histogram-cryptic.txt-rev";
x <- "Proportion of cryptic-site isoforms assigned FPKM at least 2";
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

infile1 <- "supported-cryptic-sim.txt-rev3";
infile2 <- "supported-cryptic2.txt-rev3";
x <- "Proportion of cryptic-site isoforms supported by at least three spliced reads";
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
infile1 <- "random-readcounts-pos.txt-rev3";
infile2 <- "readcounts-pos.txt-rev3";
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
legend("topright",legend=c("Non-disrupted sites","Disrupted sites"),
       lty=c(1,1),lwd=c(2,2),col=c("blue","red"));

#===
dev.off();


