#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $SLURM_DIR="$ASSEMBLY/combiner-slurms";

for(my $i=1 ; $i<=90 ; ++$i) {
  my $slurm="$SLURM_DIR/$i.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH -J COMB$i
#SBATCH -o $SLURM_DIR/$i.output
#SBATCH -e $SLURM_DIR/$i.output
#SBATCH -A COMB$i
#SBATCH --mem 10000
#SBATCH -p all
#
/home/bmajoros/1000G/src/combine-assembled-genomes.pl $ASSEMBLY/partitions/partition-$i.txt

";
  close(OUT);
}



