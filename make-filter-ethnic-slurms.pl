#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined-ethnic";
my $SLURM_DIR="$ASSEMBLY/filter-ethnic-slurms";

my @dirs=("AFR","AMR","EAS","EUR","SAS");
#my @dirs=`ls $COMBINED`;

my $slurmID=1;
foreach my $subdir (@dirs) {
  chomp $subdir;
  my $dir="$COMBINED/$subdir";
  my $slurm="$SLURM_DIR/$slurmID.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH -J filter$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A filter$slurmID
#SBATCH -p all
#
cd $SLURM_DIR
/home/bmajoros/FBI/essex-filter.pl $dir/1.essex $dir/1-filtered.essex
";
  close(OUT);
  ++$slurmID;
}


