#!/usr/bin/Rscript --vanilla

resolution <- 1;
infile1 <- "neg-reads-per-junction.txt";
infile2 <- "pos-reads-per-junction.txt";
x <- "Reads per junction";
y <- "Relative frequency";
outfile <- "reads-per-junction.pdf"

data1 <- read.table(infile1);
data2 <- read.table(infile2);

pdf(outfile);
par(mfrow=c(2,1))
h1 <- hist(data1$V1,breaks=seq(0,90,resolution),plot=F);
h2 <- hist(data2$V1,breaks=seq(0,90,resolution),plot=F);
h1$density = h1$counts/sum(h1$counts);
h2$density = h2$counts/sum(h2$counts);
plot(h1,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,90),ylim=c(0,0.6),xlab=x,ylab=y,freq=F,main="Reads per junction in simulated isoforms");
plot(h2,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,90),ylim=c(0,0.12),xlab=x,ylab=y,freq=F,main="Reads per junction in ICE isoforms");
dev.off();
