#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined-hg19";
my $SLURM_DIR="$ASSEMBLY/cryptic-slurms";

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
#SBATCH -J cryptic$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A cryptic$slurmID
#
cd $SLURM_DIR
/home/bmajoros/1000G/src/count-cryptic.pl $dir/1.essex > $dir/cryptic-1.txt
/home/bmajoros/1000G/src/count-cryptic.pl $dir/2.essex > $dir/cryptic-2.txt
";
  close(OUT);
  ++$slurmID;
}



