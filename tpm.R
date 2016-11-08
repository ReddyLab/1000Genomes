#!/usr/bin/env Rscript


outfile <- "tpm.pdf"
pdf(outfile);
stringtie <- read.table("/home/bmajoros/1000G/assembly/stringtie.tpm")
salmon <- read.table("/home/bmajoros/1000G/assembly/salmon.tpm")
kallisto <- read.table("/home/bmajoros/1000G/assembly/kallisto.tpm")

x <- "TPM threshold"
y <- "Alternative isoforms above TPM"
plot(salmon,col="red",xlab=x,ylab=y,main="",lwd=2,type="l");
lines(kallisto,col="blue",lwd=2)
lines(stringtie,col="green",lwd=2)
legend("topright",legend=c("Salmon","Kallisto","StringTie"),
       lty=c(1,1),lwd=c(2,2),col=c("red","blue","green"));
dev.off();


