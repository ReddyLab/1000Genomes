#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $REF_FASTA="$COMBINED/ref/1.fasta";
my $SLURM_DIR="$ASSEMBLY/fbi-slurms";

my @dirs=`ls $COMBINED`;
my $slurmID=1;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $slurm="$SLURM_DIR/$slurmID.slurm";
  unlink("$dir/1.essex") if -e "$dir/1.essex";
  unlink("$dir/2.essex") if -e "$dir/2.essex";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH -J FBI$slurmID
#SBATCH -o $SLURM_DIR/$slurmID.output
#SBATCH -e $SLURM_DIR/$slurmID.output
#SBATCH -A FBI$slurmID
#SBATCH --mem 10000
#
cd $dir

/home/bmajoros/FBI/fbi.pl /home/bmajoros/1000G/FBI/model $REF_FASTA $dir/1.fasta /home/bmajoros/1000G/assembly/local-CDS-and-UTR.gff $dir/1.essex

/home/bmajoros/FBI/fbi.pl /home/bmajoros/1000G/FBI/model $REF_FASTA $dir/2.fasta /home/bmajoros/1000G/assembly/local-CDS-and-UTR.gff $dir/2.essex

";
  close(OUT);
  ++$slurmID;
}



