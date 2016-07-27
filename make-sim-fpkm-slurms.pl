#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/sim-fpkm-slurms";
my $PROGRAM="$THOUSAND/src/get-sim-fpkm.pl";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";
  $slurm->addCommand("$PROGRAM $dir/1.gff $dir/2.gff $dir/1.blacklist $dir/2.blacklist $dir/RNA/tab.txt > $dir/fpkm-real.txt");
  $slurm->addCommand("$PROGRAM $dir/random-1.gff $dir/random-2.gff $dir/random-1.blacklist $dir/random-2.blacklist $dir/RNA/sim/tab.txt > $dir/fpkm-sim.txt");
}

$slurm->nice(500);
$slurm->mem(3000);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"FPKM","",890);


