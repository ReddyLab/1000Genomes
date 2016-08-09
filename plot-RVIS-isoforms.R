#!/usr/bin/Rscript --vanilla

resolution <- 2;
infile1 <- "isoform-counts-RVIS.txt";
infile2 <- "isoform-counts-bkg.txt";

x <- "Number of isoforms per gene";
y <- "Relative frequency";
outfile <- "RVIS-isoforms2.pdf"

data1 <- read.table(infile1);
data2 <- read.table(infile2);

pdf(outfile);
par(mfrow=c(2,1))
h1 <- hist(data1$V1,breaks=seq(0,85,resolution),plot=F);
h2 <- hist(data2$V1,breaks=seq(0,85,resolution),plot=F);
plot(h1,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,85),ylim=c(0,0.3),xlab=x,ylab=y,freq=F,main="Isoforms per gene in low-RVIS genes having an inactivated transcript");
plot(h2,col=rgb(0.1,0.1,0.1,1/4),xlim=c(0,85),ylim=c(0,0.3),xlab=x,ylab=y,freq=F,main="Isoforms per gene in GENCODE");
dev.off();

#pdf(outfile);
#h1 <- density(data1$V1,plot=F);
#h2 <- density(data2$V1,plot=F);
#plot(h1,xlim=c(0,85),xlab=x,ylab=y);
#lines(h2,xlim=c(0,85),lty=2);
#dev.off();

