#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $SLURM_DIR="$ASSEMBLY/combiner-slurms";

for(my $i=0 ; $i<30 ; ++$i) {
  my $slurm="$SLURM_DIR/$i.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH -J COMBINE$i
#SBATCH -o $SLURM_DIR/$i.output
#SBATCH -e $SLURM_DIR/$i.output
#SBATCH -A COMBINE$i
#SBATCH --mem 10000
#SBATCH -p all
#
/home/bmajoros/1000G/src/combine-parallel.pl $i

";
  close(OUT);
}



