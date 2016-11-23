#!/bin/env Rscript

args <- commandArgs(TRUE)
if(length(args)!=3) {
  cat("usage: <set1.txt> <set2.txt> <greater|less|two.sided>\n");
  q(status=1)
}
infile1 <- args[1];
infile2 <- args[2];
comp <- args[3]

data1 <- read.table(infile1)
data2 <- read.table(infile2)

wilcox.test(data1$V1,data2$V1,comp)



