#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
if(length(args)!=3) {
  cat("usage: high.txt low.txt out.pdf\n");
  q(status=1)
}
highFile <- args[1]
lowFile <- args[2]
outFile <- args[3]

BASE=2
PSEUDOCOUNT=0.0001 # 0.0001
BANDWIDTH=0.5  # 0.9
MAXY<- 0.6 # 0.4

x <- "Log2(Normalized read counts)";
y <- "Density";
data1 <- read.table(highFile);
data2 <- read.table(lowFile);

###
old1 <- data1
old2 <- data2
data1 <- log(data1+PSEUDOCOUNT)/log(BASE)
data2 <- log(data2+PSEUDOCOUNT)/log(BASE)
###

h1 <- density(data1$V1,bw=BANDWIDTH);
h2 <- density(data2$V1,bw=BANDWIDTH);
min1 <- min(data1$V1); max1 <- max(data1$V1);
min2 <- min(data2$V1); max2 <- max(data2$V1);
minX <- min(min1,min2); maxX <- max(max1,max2);

minX <- -15

pdf(outFile);
par(mfrow=c(2,1))
plot(h1,col="red",xlim=c(minX,maxX),ylim=c(0,MAXY),xlab=x,ylab=y,main="",
     lwd=2);
lines(h2,col="blue",xlim=c(minX,maxX),lwd=2);
#abline(v=log(mean(old1$V1))/log(2),col="red",lty=3)
#abline(v=log(mean(old2$V1))/log(2),col="blue",lty=3)

legend("topright",legend=c("P(isoform)<0.1","P(isoform)>0.9"),
       lty=c(1,1),lwd=c(2,2),col=c("blue","red"));
wilcox.test(data1$V1,data2$V1,alternative="greater")

print("means:")
mean(old1$V1)
mean(old2$V1)
print("medians:")
median(old1$V1)
median(old2$V1)
dev.off()

