#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $KEEP="$THOUSAND/assembly/nonblacklist-sims.txt";

my %keep;
open(IN,$KEEP) || die "can't open $KEEP";
while(<IN>) {
  chomp; $keep{$_}=1
}
close(IN);

my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  next unless -e "$COMBINED/$indiv/RNA/stringtie.gff";
  my (%blacklist,%sims);
  my $dir="$COMBINED/$indiv";
  my $sim="$dir/RNA/sim";
  loadBlacklist("$dir/random-1.blacklist",\%blacklist);
  loadBlacklist("$dir/random-2.blacklist",\%blacklist);
  loadGFF("$dir/random-1.gff",1,\%sims,\%blacklist);
  loadGFF("$dir/random-2.gff",2,\%sims,\%blacklist);
  processRNA("$sim/tab.txt",\%sims,\%blacklist);
}



sub processRNA
{
  my ($filename,$sims,$blacklist)=@_;
  open(IN,$filename) || die "can't open $filename";
  <IN>; # header line
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=7;
    my ($indiv,$allele,$gene,$transcript,$cov,$fpkm,$tpm)=@fields;
    if($transcript=~/^SIM\d+_(\S+)/) {
      my $id=$1;
      next unless $keep{$id};
      my $key="$allele $transcript";
      if($blacklist->{$key}) { next }
      #if($blacklist->{$key}) { print "blacklist\t$transcript\t$fpkm\n" }
      else { print "simulated\t$indiv\t$gene\t$id\t$fpkm\n" }
    }
    else {
      next unless $keep{$transcript};
      print "wildtype\t$indiv\t$gene\t$transcript\t$fpkm\n";
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
    my $transcript=$1;
    $transcript=~/^SIM\d+_(\S+)/ || die $transcript;
    my $id=$1;
    next unless $keep{$id};
    my $sim="$allele $transcript";
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
    $sim=~/^SIM\d+_(\S+)/ || die $sim;
    next unless $keep{$1};
    my $key="$hap $sim";
    $hash->{$key}=1;
  }
  close(IN);
}



