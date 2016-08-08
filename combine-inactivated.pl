#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  process("$COMBINED/$indiv/1-inactivated.txt",$indiv,1);
  process("$COMBINED/$indiv/2-inactivated.txt",$indiv,2);
}


sub process {
  my ($filename,$indiv,$allele)=@_;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$what,$why)=@fields;
    print "$indiv\t$allele\t$gene\t$transcript\n";
  }
  close(IN);
}




#======================================================================
#======================================================================
#=====================================================
#=====================================================
#=====================================================
#=====================================================


