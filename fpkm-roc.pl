#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";

my $real=load("$ASSEMBLY/fpkm-real.txt"); my $numReal=@$real;
my $sim=load("$ASSEMBLY/fpkm-sim.txt"); my $numSim=@$sim;

print "0\t0\n";
my $realPointer=$numReal-1; my $simPointer=$numSim-1;
for(; $simPointer>=0 ; --$simPointer) {
  my $simAbove=$numSim-$simPointer;
  my $simProportion=$simAbove/$numSim;
  my $threshold=$sim->[$simPointer];
  #print "BEFORE: sp=$simPointer rp=$realPointer th=$threshold\n";
  while($realPointer>=0 && $real->[$realPointer]>=$threshold) {--$realPointer}
  #print "AFTER: sp=$simPointer rp=$realPointer th=$threshold\n";
  my $realAbove=$numReal-$realPointer;
  if($realPointer<0) { $realAbove=$numReal }
  my $realProportion=$realAbove/$numReal;
  print "$simProportion\t$realProportion\n";
}



sub load {
  my ($filename)=@_;
  my $array=[];
  open(IN,$filename) || die "can't open $filename";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($transcript,$fpkm)=@fields;
    push @$array,$fpkm;
  }
  close(IN);
  @$array=sort {$a <=> $b} @$array;
  return $array;
}








