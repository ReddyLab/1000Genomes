#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $INFILE="mapped.gff";
my $OUTFILE="reformatted.gff";
my $SLURM_DIR="$ASSEMBLY/reformat-slurms";

my @dirs=`ls $COMBINED`;
my $slurmID=1;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $infile="$COMBINED/$subdir/$INFILE";
  my $outfile="$COMBINED/$subdir/$OUTFILE";
  system("rm $outfile") if -e $outfile;
  my $slurm="$SLURM_DIR/$slurmID.slurm";
  die unless -e $infile;
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH -J format$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A format$slurmID
#
cd $SLURM_DIR
$THOUSAND/src/reformat.pl $infile $outfile
";
  close(OUT);
  ++$slurmID;
}



