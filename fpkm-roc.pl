#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <threshold>\n" unless @ARGV==1;
my ($THRESHOLD)=@ARGV;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";

#my $real=load("$ASSEMBLY/fpkm-real.txt"); my $numReal=@$real;
#my $sim=load("$ASSEMBLY/fpkm-sim.txt"); my $numSim=@$sim;
#my $real=load("$ASSEMBLY/fpkm-real-2.txt"); my $numReal=@$real;
#my $sim=load("$ASSEMBLY/fpkm-sim-2.txt"); my $numSim=@$sim;
my $real=load("$ASSEMBLY/fpkm-real-3.txt"); my $numReal=@$real;
my $sim=load("$ASSEMBLY/fpkm-sim-3.txt"); my $numSim=@$sim;

print "0\t0\n";
my $realPointer=$numReal-1; my $simPointer=$numSim-1;
for(; $simPointer>=0 ; --$simPointer) {
  my $threshold=$sim->[$simPointer];
  while($simPointer>0 && $sim->[$simPointer-1]>=$threshold) { --$simPointer }
  my $simAbove=$numSim-$simPointer;
  my $simProportion=$simAbove/$numSim;
  #print "BEFORE: sp=$simPointer rp=$realPointer th=$threshold\n";
  while($realPointer>=0 && $real->[$realPointer]>=$threshold) {--$realPointer}
  #print "AFTER: sp=$simPointer rp=$realPointer th=$threshold\n";
  my $realAbove=$numReal-$realPointer;
  if($realPointer<0) { $realAbove=$numReal }
  my $realProportion=$realAbove/$numReal;
  #if($realProportion>=1) { print "$threshold\t$realProportion\t$simProportion\n" }
  #print "$simProportion\t$realProportion\t\t$threshold\n";
  print "$simProportion\t$realProportion\n";
}

my $realIndex=threshold($real,$THRESHOLD);
my $simIndex=threshold($sim,$THRESHOLD);
my $realProportion=($numReal-$realIndex)/$numReal;
my $simProportion=($numSim-$simIndex)/$numSim;
$realProportion=int($realProportion*1000+5/9)/1000;
$simProportion=int($simProportion*1000+5/9)/1000;
print STDERR "at threshold=$THRESHOLD:\treal=$realProportion\tsim=$simProportion\n";


sub threshold {
  my ($array,$cutoff)=@_;
  my $n=@$array;
  for(my $i=0 ; $i<$n ; ++$i) {
    if($array->[$i]>=$cutoff) { return $i }
  }
  return $n;
}


sub load {
  my ($filename)=@_;
  my $array=[];
  open(IN,$filename) || die "can't open $filename";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($transcript,$fpkm)=@fields;

    next unless $fpkm>0; ###

    push @$array,$fpkm;
  }
  close(IN);
  @$array=sort {$a <=> $b} @$array;
  return $array;
}








