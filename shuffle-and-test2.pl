#!/usr/bin/perl
use strict;

for(my $i=0 ; $i<1000 ; ++$i) {
  system("~/1000G/src/analyze-SR.py raw-allframes-betas-elastic.txt hnrnp.txt 1 > shuffleds.txt ; ~/1000G/src/wilcox1.R shuffleds.txt | grep V >> logistic-shuffled.txt")
}
