#!/usr/bin/perl
use strict;

my @fastq=`ls /data/common/1000_genomes/RNA/fastq/*.fastq.gz`;
foreach my $infile (@fastq) {

  my $cmd="java -jar /data/reddylab/software/Trimmomatic-0.33/Trimmomatic-0.33/trimmomatic-0.33.jar PE -phred33 -threads 8 /data/common/1000_genomes/RNA/fastq/ERR188042_1.fastq.gz /data/common/1000_genomes/RNA/fastq/ERR188042_2.fastq.gz paired1.fq.gz unpaired1.fq.gz paired2.fq.gz unpaired2.fq.gz ILLUMINACLIP:/data/reddylab/software/Trimmomatic-0.33/Trimmomatic-0.33/adapters/TruSeq3-PE-2.fa:2:30:15:1:true HEADCROP:1 LEADING:30 SLIDINGWINDOW:7:20 MINLEN:30";

}



