#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/ice9-nmd-slurms";
my $PROGRAM="/home/bmajoros/1000G/src/ice9-get-nmd.pl";

my $slurm=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  next unless -e "$dir/RNA/stringtie.gff";
  $slurm->addCommand("$PROGRAM $indiv 1 $dir/1.ice9 $dir/1.ice9-nmd");
  $slurm->addCommand("$PROGRAM $indiv 2 $dir/2.ice9 $dir/2.ice9-nmd");
#  $slurm->addCommand("$PROGRAM $indiv 1 $dir/random-1.essex $dir/random-1.alts-with-nmd");
#  $slurm->addCommand("$PROGRAM $indiv 2 $dir/random-2.essex $dir/random-2.alts-with-nmd");
}
#$slurm->mem(5000);
$slurm->setQueue("new,all");
$slurm->nice(500); # turns on "nice" (sets it to 100 by default)
$slurm->writeArrayScript($SLURM_DIR,"ALTNMD",$SLURM_DIR,1000);


