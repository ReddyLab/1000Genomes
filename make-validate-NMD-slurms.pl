#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined-hg19";
my $SLURM_DIR="$ASSEMBLY/validate-NMD-slurms";

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
#SBATCH -J NMD$slurmID
#SBATCH -o $SLURM_DIR/$slurmID.output
#SBATCH -e $SLURM_DIR/$slurmID.output
#SBATCH -A NMD$slurmID
#SBATCH --mem 10000
#
cd $dir

/home/bmajoros/1000G/src/validate-NMD-predictions.pl $dir > $dir/nmd.txt

";
  close(OUT);
  ++$slurmID;
}



