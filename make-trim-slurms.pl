#!/usr/bin/perl
use strict;
use SlurmWriter;

my $NUM_JOBS=100;
my $FASTQ_DIR="/data/common/1000_genomes/RNA/fastq";
my $ANALYSIS_DIR="/data/reddylab/Reference_Data/1000Genomes/analysis/trim";
my $SLURM_DIR="$ANALYSIS_DIR/slurm";
my $OUT_DIR="$ANALYSIS_DIR/output";
my $UNPAIRED_DIR="$ANALYSIS_DIR/output/unpaired";
my $ADAPTERS="/data/reddylab/software/Trimmomatic-0.33/Trimmomatic-0.33/adapters/TruSeq3-PE-2.fa";

if(-e $SLURM_DIR) { system("rm -r $SLURM_DIR") }
system("mkdir -p $SLURM_DIR");
system("mkdir -p $OUT_DIR");
system("mkdir -p $UNPAIRED_DIR");
my $slurm=new SlurmWriter;
$slurm->nice();
$slurm->mem(4000);
my @fastq=`ls $FASTQ_DIR/*.fastq.gz`;
foreach my $infile (@fastq) {
  next unless($infile=~/([^\/]+)_1.fastq.gz/);
  my $id=$1;
  my $infile1="$FASTQ_DIR/${id}_1.fastq.gz";
  my $infile2="$FASTQ_DIR/${id}_2.fastq.gz";
  my $outfile1="$OUT_DIR/${id}_1.fastq.gz";
  my $outfile2="$OUT_DIR/${id}_2.fastq.gz";
  my $unpaired1="$UNPAIRED_DIR/${id}_1_unpaired.fastq.gz";
  my $unpaired2="$UNPAIRED_DIR/${id}_2_unpaired.fastq.gz";
  my $cmd="java -jar /data/reddylab/software/Trimmomatic-0.33/Trimmomatic-0.33/trimmomatic-0.33.jar PE -phred33 -threads 1 $infile1 $infile2 $outfile1 $unpaired1 $outfile2 $unpaired2 ILLUMINACLIP:$ADAPTERS:2:30:15:1:true HEADCROP:1 LEADING:30 SLIDINGWINDOW:7:20 MINLEN:30";
  $slurm->addCommand($cmd);
}

$slurm->writeScripts($NUM_JOBS,$SLURM_DIR,"trim","lowmem",$ANALYSIS_DIR);


