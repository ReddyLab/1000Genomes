#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $INFILE="mapped.gff";
my $SLURM_DIR="$ASSEMBLY/check-splice-slurms";

my @dirs=`ls $COMBINED`;
my $slurmID=1;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $outfile="$COMBINED/$subdir/splice-sites.txt";
  system("rm $outfile") if -e $outfile;
  my $slurm="$SLURM_DIR/$slurmID.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH -J splice$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A splice$slurmID
#
cd $SLURM_DIR
$THOUSAND/src/check-alt-splice-sites.pl $subdir > $outfile
";
  close(OUT);
  ++$slurmID;
}



