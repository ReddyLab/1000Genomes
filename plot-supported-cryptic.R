#!/usr/bin/Rscript --vanilla

resolution <- 0.01;
infile1 <- "supported-cryptic-sim.txt";
infile2 <- "supported-cryptic.txt";
x <- "Proportion of cryptic-site isoforms supported by at least one spliced read";
y <- "Frequency";
outfile <- "support-cryptic.pdf"

data1 <- read.table(infile1);
data2 <- read.table(infile2);

pdf(outfile);
par(mfrow=c(2,1))
h1 <- hist(data1$V1,breaks=seq(0,0.5,resolution),plot=F);
h2 <- hist(data2$V1,breaks=seq(0,0.5,resolution),plot=F);
#h1$density = h1$counts/sum(h1$counts);
#h2$density = h2$counts/sum(h2$counts);
plot(h1,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,0.4),xlab=x,ylab=y,freq=F,main="Simulated cryptic-site isoforms supported by\nat least one spliced read");
plot(h2,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,0.4),xlab=x,ylab=y,freq=F,main="ICE cryptic-site isoforms supported by\nat least one spliced read");
dev.off();

