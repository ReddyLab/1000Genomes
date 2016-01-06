#!/usr/bin/perl
use strict;

my $BASEDIR="/data/reddylab/Reference_Data/1000Genomes/analysis/assembly/combined";
my $IDs="/data/reddylab/Reference_Data/1000Genomes/analysis/assembly/Geuvadis-keep.txt";
my $SLURMS="$BASEDIR/index-slurms";

my @IDs;
open(IN,$IDs) || die $IDs;
while(<IN>) { chomp; push @IDs,$_ }
close(IN);

foreach my $ID (@IDs) {
  my $dir="$BASEDIR/$ID";
  my $slurm="$SLURMS/$ID.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH --get-user-env
#SBATCH -J $ID
#SBATCH -o $ID.output
#SBATCH -e $ID.output
#SBATCH -A $ID
#SBATCH --mem 100000
#SBATCH --cpus-per-task=1
#
cd $dir
/data/reddylab/software/STAR_2.4.2a/STAR-STAR_2.4.2a/bin/Linux_x86_64/STAR \\
   --runMode genomeGenerate \\
   --genomeDir $dir \\
   --genomeFastaFiles $dir/*.fasta \\
   --runThreadN 32
";
  close(OUT);

}

