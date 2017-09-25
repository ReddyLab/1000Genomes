#!/usr/bin/perl
use strict;

for(my $i=0 ; $i<1000 ; ++$i) {
  system("~/1000G/src/analyze-SR.py shendure+3.txt hnrnp.txt 1 > shuffled.txt ; ~/1000G/src/wilcox1.R shuffled.txt | grep V >> shendure-shuffled.txt")
}
