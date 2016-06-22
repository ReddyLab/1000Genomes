#!/usr/bin/Rscript --vanilla
data <- read.table("nmd-hist-data.txt")
mean(data[,1])
n <- nrow(data)
s <- sd(data[,1])
SE <- s/sqrt(n);
E <- qt(0.975, n-1)*SE
E
mean(data[,1])-E
mean(data[,1])+E

