#!/usr/bin/perl
use strict;
use SummaryStats;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $POP_FILE="$ASSEMBLY/populations.txt";

my (%pop,%sumX,%sumXX,%N);
open(IN,$POP_FILE) || die "can't open file: $POP_FILE";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($indiv,$pop)=@fields;
  $pop{$indiv}=$pop;
}
close(IN);

my @dirs=`ls $COMBINED`;
my $n=@dirs;
for(my $i=0 ; $i<$n ; ++$i) {
  my $dir=$dirs[$i];
  chomp $dir;
  $dir=~/([^\/]+)$/ || die $dir;
  my $indiv=$1;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $pop=$pop{$indiv};
  process("$COMBINED/$dir/1-variant-counts.txt",$pop);
  process("$COMBINED/$dir/2-variant-counts.txt",$pop);
}

my @pops=keys %N;
print "\t";
foreach my $pop (@pops) { print "$pop\t" }
print "\n";
my @types=keys %{$N{$pops[0]}};
foreach my $type (@types) {
  print "$type\t";
  foreach my $pop (@pops) {
    my $N=$N{$pop}->{$type};
    my $sumX=$sumX{$pop}->{$type};
    my $sumXX=$sumXX{$pop}->{$type};
    my $mean=$sumX/$N;
    my $var=$N>1 ? ($sumXX-$sumX*$sumX/$N)/($N-1) : undef;
    if($var<0) {$var=0}
    my $sd=sqrt($var);
    print "$mean\($sd)\t";
  }
  print "\n";
}


sub process
{
  my ($file,$pop)=@_;
  open(IN,$file) || die "can't open file: $file";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=5;
    my ($type,$mean,$sumX,$sumXX,$N)=@fields;
    $sumX{$pop}->{$type}+=$sumX;
    $sumXX{$pop}->{$type}+=$sumXX;
    $N{$pop}->{$type}+=$N;
  }
  close(IN);
}



