#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  next unless -e "$dir/RNA/stringtie.gff";
  process("$COMBINED/$indiv/1.crypskip",$indiv,1);
  process("$COMBINED/$indiv/2.crypskip",$indiv,2);
}


sub process {
  my ($infile,$indiv,$hap)=@_;
  open(IN,$infile) || die $infile;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    print "$indiv\t$hap\t$_\n";
  }
  close(IN);
}




