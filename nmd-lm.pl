#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $INFILE="$COMBINED/analyze-nmd.txt";
my $HIST_OUT="$COMBINED/nmd-hist-data.txt";
my $LM_OUT="$COMBINED/nmd-lm.txt";

open(HIST,">$HIST_OUT") || die $HIST_OUT;
open(LM,">$LM_OUT") || die $LM_OUT;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($chr,$transcriptID,$mean0,$mean1,$mean2,$n0,$n1,$n2)=@fields;
  my $n01=$n0+$n1; my $mean01=($mean0*$n0+$mean1*$n1)/$n01;
  next unless $n01>=5 && $n2>=5 && $mean2>=1;
  my $ratio=$mean01/$mean2;
  print HIST "$ratio\n";
  my $norm0=$mean0/$mean2;
  my $norm1=$mean1/$mean2;
  my $norm2=$mean2/$mean2;
  if($n0>=2) { print LM "0\t$norm0\n" }
  if($n1>=5) { print LM "1\t$norm1\n" }
  if($n2>=5) { print LM "2\t$norm2\n" }
}
close(IN);
close(HIST);
close(LM);


