#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $OUTPUTS="$THOUSAND/fbi-slurms/outputs/old";

my @files=`ls $OUTPUTS`;
foreach my $file (@files) {
  chomp $file; next unless $file=~/.output/;
  my @dates;
  open(IN,"grep EDT $OUTPUTS/$file |") || die $file;
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
  my $elapsed;
  if($day1==$day2) { $elapsed=$hour2-$hour1 }
  elsif($day2>$day1) {$elapsed=24-$hour1+$hour2+24*($day2-$day1-1)}
  else { die "$day1 $hour1 - $day2 $hour2\n" }
  print "$elapsed hours\n";
}





