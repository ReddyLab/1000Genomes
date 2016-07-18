#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/blacklist-slurms";
my $PROGRAM="/home/bmajoros/1000G/src/make-ALT-blacklist.pl";

my $slurm=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  next unless -e "$dir/RNA/stringtie.gff";
  $slurm->addCommand("$PROGRAM $indiv 1 $dir/1.essex ALT $dir/1.blacklist");
  $slurm->addCommand("$PROGRAM $indiv 2 $dir/2.essex ALT $dir/2.blacklist");
  $slurm->addCommand("$PROGRAM $indiv 1 $dir/random-1.essex SIM $dir/random-1.blacklist");
  $slurm->addCommand("$PROGRAM $indiv 2 $dir/random-2.essex SIM $dir/random-2.blacklist");
}
$slurm->mem(5000);
$slurm->setQueue("new,all");
$slurm->nice(500); # turns on "nice" (sets it to 100 by default)
$slurm->writeArrayScript($SLURM_DIR,"BLACK",$SLURM_DIR,800);


