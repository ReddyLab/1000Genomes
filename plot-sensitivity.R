#!/usr/bin/Rscript --vanilla

resolution <- 0.005;
infile1 <- "sensitivity-histogram.txt";
infile2 <- "proposal-histogram.txt";

x <- "Proportion of ICE-predicted alternate isoforms found by StringTie";
y <- "Frequency";
outfile <- "sensitivity.pdf"

data1 <- read.table(infile1);
data2 <- read.table(infile2);

pdf(outfile);
par(mfrow=c(2,1))
h1 <- hist(data1$V1,breaks=seq(0,0.3,resolution),plot=F);
h2 <- hist(data2$V1,breaks=seq(0,0.3,resolution),plot=F);
#h1$density = h1$counts/sum(h1$counts);
#h2$density = h2$counts/sum(h2$counts);
plot(h1,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,0.3),xlab=x,ylab=y,freq=F,main="ICE-predicted isoforms found by StringTie\nwithout access to ICE predictions");
plot(h2,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,0.3),xlab=x,ylab=y,freq=F,main="ICE-predicted isoforms found by StringTie\nwith access to ICE predictions");
dev.off();

