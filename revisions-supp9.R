#!/usr/bin/env Rscript


#====

#outfile <- "supp9-rev.pdf"
outfile <- "supp9-rev_unfiltered.pdf"

pdf(outfile);
par(mfrow=c(2,1))

#====

infile1 <- "supported-skipping-blind.txt-rev3";
infile2 <- "supported-skipping-real.txt-rev3";
x <- "Proportion of exon-skipping isoforms supported by at least three spliced reads";
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
infile1 <- "sensitivity-histogram-skipping.txt-rev";
infile2 <- "proposal-histogram-skipping.txt-rev";
x <- "Proportion of exon-skipping isoforms assigned FPKM at least 2";
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

infile1 <- "supported-skipping-sim.txt-rev3";
infile2 <- "supported-skipping.txt-rev3";
x <- "Proportion of exon-skipping isoforms supported by at least three spliced reads";
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
#infile1 <- "random-readcounts-pos.txt-rev3";
#infile2 <- "readcounts-pos.txt-rev3";
infile1 <- "random-readcounts-pos.txt-rev3_unfiltered";
infile2 <- "readcounts-pos.txt-rev3_unfiltered";
#x <- "Log10(normalized reads per junction)";
x <- "Normalized reads per junction";
y <- "Density";
#data1 <- log10(read.table(infile1));
#data2 <- log10(read.table(infile2));
data1 <- read.table(infile1);
data2 <- read.table(infile2);
min1 <- min(data1$V1); max1 <- max(data1$V1);
min2 <- min(data2$V1); max2 <- max(data2$V1);
minX <- min(min1,min2); maxX <- max(max1,max2);
maxX<-0.2
#h1 <- density(data1$V1);
#h2 <- density(data2$V1);
breaks=seq(0,2.1,0.0025)
#breaks=seq(minX,maxX,0.01)
h1 <- hist(data1$V1,plot=F,breaks=breaks);
h2 <- hist(data2$V1,plot=F,breaks=breaks);
plot(h1,col="lightgray",xlim=c(0,maxX),xlab=x,ylab=y,main="");
plot(h2,col="lightgray",xlim=c(0,maxX),xlab=x,ylab=y,main="");
#lines(h2,col="red",lwd=2);
#legend("topright",legend=c("Non-disrupted sites","Disrupted sites"),
#       lty=c(1,1),lwd=c(2,2),col=c("blue","red"));

wilcox.test(data2$V1,data1$V1,alternative="greater")

#===
dev.off();


