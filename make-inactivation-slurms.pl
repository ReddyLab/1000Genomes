#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/inactivation-slurms";

my @dirs=`ls $COMBINED`;
my $slurmID=1;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $slurm="$SLURM_DIR/$slurmID.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH -J LOF$slurmID
#SBATCH -o $SLURM_DIR/$slurmID.output
#SBATCH -e $SLURM_DIR/$slurmID.output
#SBATCH -A LOF$slurmID
#
cd $dir
$THOUSAND/src/essex-get-inactive.pl 1.essex > 1-inactivated.txt
$THOUSAND/src/essex-get-inactive.pl 2.essex > 2-inactivated.txt
";
  close(OUT);
  ++$slurmID;
}



