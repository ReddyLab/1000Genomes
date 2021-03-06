#!/usr/bin/perl
use strict;

my $CPUs=8;
my $MEMORY=40000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $RNA_LIST="$THOUSAND/assembly/id-map-parsed.txt";
my $SLURMS="$THOUSAND/assembly/RNA-ref-slurms";
my $FASTQ="$THOUSAND/trim/output";

my @IDs;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  push @IDs,$subdir;
}

my %rnaHash;
open(IN,$RNA_LIST) || die $RNA_LIST;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields>=2;
  my ($rnaID,$indivID)=@fields;
  $rnaHash{$indivID}=$rnaID;
}
close(IN);

my $slurmID=1;
foreach my $ID (@IDs) {
  my $rnaID=$rnaHash{$ID};
  if(!$rnaID) { next }
  my $dir="$COMBINED/$ID";
  my $slurm="$SLURMS/$slurmID.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH --get-user-env
#SBATCH -J REF$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A REF$slurmID
#SBATCH --mem $MEMORY
#SBATCH --cpus-per-task=$CPUs
#SBATCH -p all
#
module load bowtie2/2.2.4-fasrc01
module load tophat/2.0.13-gcb01

cd /home/bmajoros/1000G/assembly/combined/ref/RNA

tophat2 --output-dir $dir/RNA/ref --min-intron-length 30 --num-threads $CPUs --GTF $dir/RNA/ref/ref1.gff 1 $FASTQ/$rnaID\_1.fastq.gz $FASTQ/$rnaID\_2.fastq.gz

cd $dir/RNA/ref

/data/reddylab/software/samtools/samtools-1.1/samtools view accepted_hits.bam | /home/bmajoros/1000G/src/count-mapped-reads.pl > readcounts.txt

/data/reddylab/software/stringtie/stringtie-1.2.1.Linux_x86_64/stringtie accepted_hits.bam -G $dir/RNA/ref/ref1.gff -o stringtie-ref.gff -p $CPUs -C stringtie-ref.coverage -A stringtie-ref.abundance

rm accepted_hits.bam unmapped.bam

";
  close(OUT);
  ++$slurmID;
}

