#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/compensatory-splicing-slurms";

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
#SBATCH -J SPLICE$slurmID
#SBATCH -o $SLURM_DIR/$slurmID.output
#SBATCH -e $SLURM_DIR/$slurmID.output
#SBATCH -A SPLICE$slurmID
#
cd $dir

/home/bmajoros/1000G/src/compensatory-splicing2.pl $dir 1 > $dir/1-compensatory-splicing.txt
/home/bmajoros/1000G/src/compensatory-splicing2.pl $dir 2 > $dir/2-compensatory-splicing.txt

#/home/bmajoros/1000G/src/compensatory-splicing2.pl $subdir $dir/1.essex > $dir/1-compensatory-splicing.txt
#/home/bmajoros/1000G/src/compensatory-splicing2.pl $subdir $dir/2.essex > $dir/2-compensatory-splicing.txt

";
  close(OUT);
  ++$slurmID;
}

#SBATCH --mem 1000


