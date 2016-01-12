#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my @dirs=`ls $COMBINED`;
foreach my $dir (@dirs) {
  chomp $dir;
  next if $dir eq "ref";
  open(IN,"$COMBINED/$dir/mapped.gff") || die "$COMBINED/$dir/mapped.gff";
  open(OUT,">$COMBINED/$dir/hap.gff") || die "$COMBINED/$dir/hap.gff";
  while(<IN>) {
    chomp;
    if(/(\S+)_(\d)(.*)/) { print OUT "$1\_$2$3\_$2\n"}
  }
  close(OUT);
  close(IN);
}


