#!/bin/env Rscript

options(scipen=7)

for(i in 0:29) {
    outfile <- paste("mark",i,".pdf",sep="");
    pdf(outfile);
    par(mfrow=c(4,1));
    infile <- paste("/home/bmajoros/hapmix/joined/AMR.LOCALANC.",i,".10",sep="");
    data <- read.table(infile);
    plot(data,xlab="",ylab="",ylim=c(0,2),main="",type="l");
    dev.off();
}

