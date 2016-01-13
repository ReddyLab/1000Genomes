#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $RAW="$THOUSAND/assembly/id-map.txt";
my $FASTQ="$THOUSAND/trim/output";

my %keep;
my @files=`ls $FASTQ`;
foreach my $file (@files) {
  chomp $file;
  $file=~/(.*)_[12].fastq/ || next;
  $keep{$1}=1;
}

my %hash;
open(IN,$RAW) || die;
<IN>;
while(<IN>) {
  chomp;
  my @fields=split/\t/;
  next unless @fields>=33;
  my $hg=$fields[0];
  my $err=$fields[28];
  next unless $keep{$err};
  if(defined($hash{$hg})) {
    my $old=$hash{$hg};
    die "$err vs. $old\n" unless $old eq $err;
    next;
  }
  print "$err\t$hg\n";
  $hash{$hg}=$err;
}
close(IN);

