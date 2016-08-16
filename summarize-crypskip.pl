#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my ($CS,$Cs,$cS,$cs);
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  next unless -e "$dir/RNA/stringtie.gff";
  process("$dir/1.crypskip-counts");
  process("$dir/2.crypskip-counts");
}

print "CS=$CS Cs=$Cs cS=$cS cs=$cs\n";
System("fisher-exact-test.R $CS $Cs $cS $cs");

sub System {
  my ($cmd)=@_;
  print "$cmd\n";
  system($cmd);
}

sub process {
  my ($infile)=@_;
  open(IN,$infile) || die $infile;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($cryptic,$skipping,$crypticFound,$skippingFound)=@fields;
    print "cryptic=$cryptic => $crypticFound  skipping=$skipping => $skippingFound\n";
    next unless $cryptic>0 && $skipping>0;
    if($crypticFound>0) {
      if($skippingFound>0) {	++$CS }
      else { ++$Cs }
    }
    else {
      if($skippingFound>0) {	++$cS }
      else { ++$cs }
    }
  }
  close(IN);
}

