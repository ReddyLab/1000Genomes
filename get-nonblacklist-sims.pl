#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my %keep;
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  next unless -e "$COMBINED/$indiv/RNA/stringtie.gff";
  my (%blacklist);
  my $dir="$COMBINED/$indiv";
  my $sim="$dir/RNA/sim";
  loadBlacklist("$dir/random-1.blacklist",\%blacklist);
  loadBlacklist("$dir/random-2.blacklist",\%blacklist);
  processRNA("$sim/tab.txt",\%keep,\%blacklist);
}
my @keep=keys %keep; my $n=@keep;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$keep[$i];
  print "$transcript\n";
}


sub processRNA
{
  my ($filename,$keep,$blacklist)=@_;
  open(IN,$filename) || die "can't open $filename";
  <IN>; # header line
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=7;
    my ($indiv,$allele,$gene,$transcript,$cov,$fpkm,$tpm)=@fields;
    if($transcript=~/^SIM\d+_(\S+)/) {
      my $id=$1;
      my $key="$allele $transcript";
      if($blacklist->{$key}) { next }
      else { $keep->{$id}=1 }
    }
  }
  close(IN);
}



sub loadGFF
{
  my ($filename,$allele,$sims,$blacklist)=@_;
  open(IN,$filename) || die "can't open $filename";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=9;
    next unless $fields[1] eq "SIMULATION" && $fields[2] eq "transcript";
    $_=~/transcript_id \"([^\"]+)\";/ || die $_;
    my $sim="$allele $1";
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



