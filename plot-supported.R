#!/usr/bin/Rscript --vanilla

resolution <- 0.01;
infile1 <- "neg-supported.txt";
infile2 <- "pos-supported.txt";
x <- "Proportion of isoforms supported by at least one spliced read";
y <- "Relative frequency";
outfile <- "support.pdf"

data1 <- read.table(infile1);
data2 <- read.table(infile2);

pdf(outfile);
par(mfrow=c(2,1))
h1 <- hist(data1$V1,breaks=seq(0,0.5,resolution),plot=F);
h2 <- hist(data2$V1,breaks=seq(0,0.5,resolution),plot=F);
h1$density = h1$counts/sum(h1$counts);
h2$density = h2$counts/sum(h2$counts);
plot(h1,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,0.5),ylim=c(0,0.22),xlab=x,ylab=y,freq=F,main="Simulated isoforms supported by at least one novel spliced read");
plot(h2,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,0.5),ylim=c(0,0.22),xlab=x,ylab=y,freq=F,main="ICE isoforms supported by at least one novel spliced read");
dev.off();
