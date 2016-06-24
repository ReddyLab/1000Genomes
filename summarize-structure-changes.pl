#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $INFILE="$ASSEMBLY/structure-changes.txt";
my $CRYPTIC_FILE="$ASSEMBLY/cryptic-counts.txt";

my (%cryptic);
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$allele,$gene,$altTransID,$change)=@fields;
  $altTransID=~/ALT(\d+)_(\S+)_\d+/ || die "can't parse $altTransID";
  my ($altNum,$transcriptID)=($1,$2);
  ++$cryptic{"$transcriptID\_$allele"};
}
close(IN);

open(CRYPTIC,">$CRYPTIC_COUNTS") || die $CRYPTIC_COUNTS;
my @transcripts=keys %cryptic;
foreach my $transcript (@transcripts) {
  my $n=$cryptic{$transcript};
  print CRYPTIC "$n\n";
}
close(CRYPTIC);



