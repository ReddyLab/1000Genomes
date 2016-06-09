#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $POP_FILE="$ASSEMBLY/populations.txt";

my %pop;
open(IN,$POP_FILE) || die "can't open file: $POP_FILE";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($indiv,$pop)=@fields;
  $pop{$indiv}=$pope;
}
close(IN);

my @files=`ls $COMBINED`;
my $numFiles=@files;
for(my $i=0 ; $i<$numFiles ; ++$i) {
  my $file=$files[$i];
  chomp $file;
  $file=~// || die "can't parse filename: $file";
  open(IN,$file) || die "can't open file: $file";
  while(<IN>) {
  }
  close(IN);
}
