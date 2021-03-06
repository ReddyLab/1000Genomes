#!/usr/bin/Rscript --vanilla

#maxX <- 14
#resolution <- 0.25;
maxX <- 4
resolution <- 0.1;
#infile1 <- "random-readcounts.txt";
#infile2 <- "readcounts.txt";
infile1 <- "random-readcounts-pos.txt";
infile2 <- "readcounts-pos.txt";
#x <- "Log2(reads per junction)";
x <- "Log10(reads per junction)";
y <- "Frequency";
#outfile <- "reads-per-junction2.pdf"
outfile <- "reads-per-junction-pos-log10.pdf"
#outfile <- "reads-per-junction-pos-log2.pdf"

data1 <- log10(read.table(infile1));
data2 <- log10(read.table(infile2));
#data1 <- log2(read.table(infile1));
#data2 <- log2(read.table(infile2));

pdf(outfile);
par(mfrow=c(2,1))
h1 <- hist(data1$V1,breaks=seq(0,maxX,resolution),plot=F);
h2 <- hist(data2$V1,breaks=seq(0,maxX,resolution),plot=F);
#h1$density = h1$counts/sum(h1$counts);
#h2$density = h2$counts/sum(h2$counts);
plot(h1,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,maxX),xlab=x,ylab=y,freq=F,main="Reads per novel junction in simulated isoforms");
plot(h2,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,maxX),xlab=x,ylab=y,freq=F,main="Reads per novel junction in ICE isoforms");
dev.off();

