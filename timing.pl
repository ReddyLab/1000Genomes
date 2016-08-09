#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $OUTPUTS="$THOUSAND/fbi-slurms/outputs/old";

my @files=`ls $OUTPUTS`;
foreach my $file (@files) {
  chomp; next unless $file=~/.output/;
  my @dates;
  open(IN,$file) || die $file;
  while(<IN>) {
    if(/\S+ \S+ (\d+) (\d+):(\d+):(\d+) EDT 2016/) {
      my ($day,$hour,$min,$sec)=($1,$2,$3,$4);
      push @dates,[$day,$hour];
    }
  }
  close(IN);
  my $numDates=@dates;
  next unless $numDates==2;
  my ($day1,$hour1)=@{$dates[0]};
  my ($day2,$hour2)=@{$dates[1]};
}





