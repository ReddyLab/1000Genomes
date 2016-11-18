#!/usr/bin/env Rscript

PSEUDOCOUNT=0.0001
BANDWIDTH=0.002 #0.0002
MAXY<- 6 #300
outfile <- "ice9-highlow-noNMD-100.pdf"

pdf(outfile);
par(mfrow=c(2,1))

infile1 <- "high-reads.txt";
infile2 <- "low-reads.txt";

x <- "Normalized read counts";
y <- "Density";
data1 <- read.table(infile1);
data2 <- read.table(infile2);

###
data1 <- log(data1+PSEUDOCOUNT)/log(2)
data2 <- log(data2+PSEUDOCOUNT)/log(2)
###

h1 <- density(data1$V1,bw=BANDWIDTH);
h2 <- density(data2$V1,bw=BANDWIDTH);
min1 <- min(data1$V1); max1 <- max(data1$V1);
min2 <- min(data2$V1); max2 <- max(data2$V1);
minX <- min(min1,min2); maxX <- max(max1,max2);

plot(h1,col="red",xlim=c(minX,maxX),ylim=c(0,MAXY),xlab=x,ylab=y,main="",lwd=2);
lines(h2,col="blue",xlim=c(minX,maxX),lwd=2);
abline(v=mean(data1$V1),col="red",lty=3)
abline(v=mean(data2$V1),col="blue",lty=3)

legend("topright",legend=c("P(isoform)<0.1","P(isoform)>0.9"),
       lty=c(1,1),lwd=c(2,2),col=c("blue","red"));
wilcox.test(data1$V1,data2$V1,alternative="greater")

print("means:")
mean(data1$V1)
mean(data2$V1)
print("medians:")
median(data1$V1)
median(data2$V1)


