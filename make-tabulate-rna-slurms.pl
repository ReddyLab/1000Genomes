#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/tabulate-rna-slurms";
my $PROGRAM="/home/bmajoros/1000G/src/tabulate-rna.pl";

my $slurm=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  my $subdir="$dir/RNA";
  #my $subdir="$dir/RNA/sim";
  my $gff="$subdir/stringtie.gff";
  next unless -e $gff;
  my $outfile="$subdir/tab.txt";
  $slurm->addCommand("$PROGRAM $gff > $outfile");
}
$slurm->mem(5000);
$slurm->setQueue("new,all");
#$slurm->nice(500); # turns on "nice" (sets it to 100 by default)
$slurm->writeArrayScript($SLURM_DIR,"TAB",$SLURM_DIR,445);


