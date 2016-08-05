#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/sim-structure-change-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("$THOUSAND/src/structure-changes-sim.pl $dir/random-1.essex $dir/random-1.structure-changes $subdir 1 random-1.blacklist");
  $writer->addCommand("$THOUSAND/src/structure-changes-sim.pl $dir/random-2.essex $dir/random-2.structure-changes $subdir 2 random-2.blacklist");
}
#$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"STRUCT",$SLURM_DIR,500);

