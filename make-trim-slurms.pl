#!/usr/bin/perl
use strict;

my $FASTQ_DIR="/data/common/1000_genomes/RNA/fastq";
my $SLURM_DIR="";
my $OUT_DIR="";

my @fastq=`ls $FASTQ_DIR/*.fastq.gz`;
foreach my $infile (@fastq) {
  next unless($infile=~/([^\/]+)_1.fastq.gz/);
  my $id=$1;
  my $infile1="$FASTQ_DIR/${id}_1.fastq.gz";
  my $infile2="$FASTQ_DIR/${id}_2.fastq.gz";
  my $outfile1="";
  my $outfile2="";
  my $cmd="java -jar /data/reddylab/software/Trimmomatic-0.33/Trimmomatic-0.33/trimmomatic-0.33.jar PE -phred33 -threads 8 $infile1 $infile2 $outfile1 $unpaired1 $outfile2 $unpaired2 ILLUMINACLIP:/data/reddylab/software/Trimmomatic-0.33/Trimmomatic-0.33/adapters/TruSeq3-PE-2.fa:2:30:15:1:true HEADCROP:1 LEADING:30 SLIDINGWINDOW:7:20 MINLEN:30";

}



