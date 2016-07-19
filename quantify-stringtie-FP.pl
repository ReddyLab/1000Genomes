#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  next unless -e "$COMBINED/$indiv/RNA/stringtie.gff";
  my (%blacklist,\%sims);
  my $dir="$COMBINED/$indiv";
  my $sim="$dir/RNA/sim";
  loadBlacklist("$dir/random-1.blacklist",\%blacklist);
  loadBlacklist("$dir/random-2.blacklist",\%blacklist);
  loadGFF("$dir/random-1.gff",\%sims,\%blacklist);
  loadGFF("$dir/random-2.gff",\%sims,\%blacklist);

}



sub loadGFF
{
  my ($filename,$sims,$blacklist)=@_;
  open(IN,$filename) || die "can't open $filename";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=9;
    next unless $fields[1] eq "SIMULATION" && $fields[2] eq "transcript";
    $_=~/transcript_id \"([^\"]+)\";/ || die $_;
    my $sim=$1;
    $sims->{$sim}=1;
  }
  close(IN);
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



