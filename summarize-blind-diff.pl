#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my ($totalFound,$totalNotFound);
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $diffFile="$dir/diff.txt";
  next unless -e $diffFile;
  process($diffFile);
}
my $total=$totalFound+$totalNotFound;
my $ratio=$totalFound/$total;
print "$ratio ($totalFound\/$total) expressed ALTs were found by StringTie without annotation\n";


sub process {
  my ($infile)=@_;
  open(IN,$infile) || die "can't open $infile";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($transcriptID,$found)=@fields;
    if($found) { ++$totalFound }
    else { ++$totalNotFound }
  }
  close(IN);
}





