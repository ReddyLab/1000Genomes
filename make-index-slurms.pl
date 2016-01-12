#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $BASEDIR=$COMBINED;
my $IDs="$ASSEMBLY/Geuvadis-keep.txt";
my $SLURMS="$ASSEMBLY/index-slurms";

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
   --sjdbGTFfile $dir/hap.gff \\
   --sjdbGTFtagExonParentTranscript Parent \\
   --sjdbOverhang 74 \\
   --runThreadN 1
";
  close(OUT);

}

