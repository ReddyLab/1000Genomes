#!/usr/bin/Rscript --vanilla
library(lme4)

args <- commandArgs(TRUE)
if(length(args)!=1) {
  cat("usage: infile.txt\n");
  q(status=1)
}
infile <- args[1];
data <- read.table(infile,header=TRUE,sep=",",dec=".",strip.white=TRUE);
model <- lmer(fpkm ~ alleles + (1 | transcript), data=data)
summary(model)



