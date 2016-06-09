#!/usr/bin/perl
use strict;
use SummaryStats;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $POP_FILE="$ASSEMBLY/populations.txt";

my (%pop,%attr);
open(IN,$POP_FILE) || die "can't open file: $POP_FILE";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($indiv,$pop)=@fields;
  $pop{$indiv}=$pope;
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
  process("$COMBINED/$dir/1-status.txt",$pop);
  process("$COMBINED/$dir/2-status.txt",$pop);
}

my @pops=keys %attr;
my @attr=keys $attr{$pops[0]};



sub process
{
  my ($file,$pop)=@_;
  open(IN,$file) || die "can't open file: $file";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($key,$value)=@fields;
    push @{$attr{$pop}->{$key}},$value;
  }
  close(IN);
}
