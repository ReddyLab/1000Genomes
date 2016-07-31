#!/usr/bin/Rscript --vanilla

resolution <- 0.2;
infile1 <- "cryp-skip-sim.txt";
infile2 <- "cryp-skip-real.txt";
x <- "Ratio (# cryptic site activation + 1)/(# exon skipping + 1)";
y <- "Frequency";
outfile <- "cryp-skip.pdf"

data1 <- read.table(infile1);
data2 <- read.table(infile2);

pdf(outfile);
par(mfrow=c(2,1))
#h1 <- hist(data1$V1,plot=F);
#h2 <- hist(data2$V1,plot=F);
h1 <- hist(data1$V1,breaks=seq(0,6,resolution),plot=F);
h2 <- hist(data2$V1,breaks=seq(0,6,resolution),plot=F);
#h1$density = h1$counts/sum(h1$counts);
#h2$density = h2$counts/sum(h2$counts);
plot(h1,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,6),xlab=x,ylab=y,freq=F,main="Ratio of RNA-supported cryptic splicing\nto exon skipping in simulated isoforms");
plot(h2,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,6),xlab=x,ylab=y,freq=F,main="Ratio of RNA-supported cryptic splicing\nto exon skipping in ICE predictions");
dev.off();
