#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my (%indivsWithFrameshifts,%allIndivs);
my @dirs=`ls $COMBINED`;
foreach my $dir (@dirs) {
  chomp $dir;
  next unless $dir=~/HG\d+/ || $dir=~/NA\d+/;
  $allIndivs{$dir}=1;
  process("$COMBINED/$dir/1-indels.txt",$dir);
  process("$COMBINED/$dir/2-indels.txt",$dir);
}
my @indivs=keys %allIndivs;
my $numIndivs=@indivs;
my $numIndivsWithFrameshifts;
foreach my $indiv (@indivs) {
  if($indivsWithFrameshifts{$indiv}) { ++$numIndivsWithFrameshifts }
}
my $percentIndivsWithFrameshifts=$numIndivsWithFrameshifts/$numIndivs;
print "$percentIndivsWithFrameshifts = proportion of indivs with frameshifts\n";

sub process
{
  my ($filename,$indiv)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=5;
    if(/NOT CORRECTED/) {
      $indivsWithFrameshifts{$indiv}=1;

    }
    else {
      $indivsWithFrameshifts{$indiv}=1;

    }
  }
  close(IN);
}





