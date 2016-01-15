#!/usr/bin/perl
use strict;

my $CPUs=32;
my $THOUSAND="/home/bmajoros/1000G";
my $BASEDIR="$THOUSAND/assembly/combined";
my $IDs="$THOUSAND/assembly/Geuvadis-keep.txt";
my $RNA_LIST="$THOUSAND/assembly/id-map-parsed.txt";
my $SLURMS="$THOUSAND/assembly/STAR-slurms";
my $RNA_DIR="$THOUSAND/trim/output";

my @IDs;
open(IN,$IDs) || die $IDs;
while(<IN>) { chomp; push @IDs,$_ }
close(IN);

my %rnaHash;
open(IN,$RNA_LIST) || die $RNA_LIST;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields>=2;
  my ($rnaID,$indivID)=@fields;
  $rnaHash{$indivID}=$rnaID;
}
close(IN);

foreach my $ID (@IDs) {
  my $rnaID=$rnaHash{$ID};
  #die $ID unless $rnaID;
  if(!$rnaID) {
    print "not found: $ID\n";
    next;
  }
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
#SBATCH --mem 40000
#SBATCH --cpus-per-task=$CPUs
#
cd $dir
/data/reddylab/software/STAR_2.4.2a/STAR-STAR_2.4.2a/bin/Linux_x86_64/STAR \\
  --genomeLoad LoadAndKeep \\
  --genomeDir $dir \\
  --readFilesIn $RNA_DIR/$rnaID\_1.fastq.gz $RNA_DIR/$rnaID\_2.fastq.gz \\
  --readFilesCommand zcat \\
  --outFileNamePrefix $ID \\
  --outSAMstrandField intronMotif \\
  --sjdbOverhang 74 \\
  --runThreadN $CPUs

";
  close(OUT);

}

