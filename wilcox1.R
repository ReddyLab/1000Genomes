#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
if(length(args)!=1) {
  cat("usage: points.txt\n");
  q(status=1)
}
infile <- args[1];

data <- read.table(infile);

w<-wilcox.test(data$V1,alternative="less");


w


