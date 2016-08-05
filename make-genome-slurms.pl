#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $FASTA="$ASSEMBLY/fasta";
my $SLURM_DIR="$ASSEMBLY/genome-slurms";

for(my $i=0 ; $i<30 ; ++$i) {
  my $slurm="$SLURM_DIR/$i.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH -J GENOME$i
#SBATCH -o $SLURM_DIR/$i.output
#SBATCH -e $SLURM_DIR/$i.output
#SBATCH -A GENOME$i
#SBATCH --mem 40000
#SBATCH -p new,all
#
module load htslib/1.2.1-gcb01
module load kentUtils/v302-gcb01

cd $FASTA

/home/bmajoros/ICE/make-personal-genomes.pl /home/bmajoros/1000G/ICE/model/ice.0-43.config /home/bmajoros/1000G/assembly/gene-set/genes$i.gff /home/bmajoros/1000G/assembly/fasta/$i

";
  close(OUT);
}



