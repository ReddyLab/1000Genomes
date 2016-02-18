#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/filter-essex-slurms";

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
#SBATCH -J filter$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A filter$slurmID
#
cd $SLURM_DIR
/home/bmajoros/cia/essex-filter-errors.pl $dir/1.essex > $dir/1-filtered.essex
/home/bmajoros/cia/essex-filter-errors.pl $dir/2.essex > $dir/2-filtered.essex
";
  close(OUT);
  ++$slurmID;
}


