#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $INFILE="$COMBINED/analyze-nmd.txt";
my $HIST_OUT="$COMBINED/nmd-hist-data.txt";

open(HIST,">$HIST_OUT") || die $HIST_OUT;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($transcriptID,$mean0,$mean1,$mean2,$n0,$n1,$n2)=@fields;
  my $n01=$n0+$n1; my $mean01=($mean0*$n0+$mean1*$n1)/$n01;
  next unless $n01>=10 && $mean2>=1;
  my $ratio=$mean01/$mean2;
  print HIST "$ratio\n";
}
close(IN);
close(HIST);
