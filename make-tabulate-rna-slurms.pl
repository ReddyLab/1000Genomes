#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/tabulate-slurms";

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
#SBATCH -J tabulate$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A tabulate$slurmID
#
cd $SLURM_DIR
/home/bmajoros/1000G/src/tabulate-rna.pl $dir/RNA/stringtie.gff > $dir/RNA/tab.txt
date
";
  close(OUT);
  ++$slurmID;
}


