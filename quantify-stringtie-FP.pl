#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  next unless -e "$COMBINED/$indiv/RNA/stringtie.gff";
  my %blacklist;
  my $dir="$COMBINED/$indiv";
  my $sim="$dir/RNA/sim";
  loadBlacklist("$dir/random-1.blacklist",\%blacklist);
  loadBlacklist("$dir/random-2.blacklist",\%blacklist);


}




sub loadBlacklist
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open $filename";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=6;
    my ($indiv,$hap,$chr,$gene,$mappedTranscript,$sim)=@fields;
    my $key="$hap $sim";
    $hash->{$key}=1;
  }
  close(IN);
}



