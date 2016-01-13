#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $RAW="$THOUSAND/assembly/id-map.txt";

my %hash;
open(IN,$RAW) || die;
<IN>;
while(<IN>) {
  chomp;
  my @fields=split/\t/;
  next unless @fields>=33;
  my $hg=$fields[0];
  my $err=$fields[28];
  if(defined($hash{$hg})) {
    my $old=$hash{$hg};
    die "$err vs. $old\n" unless $old eq $err;
  }
  print "$err\t$hg\n";
  $hash{$hg}=$err;
}
close(IN);

