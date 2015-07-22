#!/usr/bin/perl
use strict;
use SlurmWriter;

my $FASTQ="/data/common/1000_genomes/RNA/fastq";
my $FASTQC="/home/bmajoros/software/fastqc/FastQC/fastqc";
my $ANALYSIS="/data/reddylab/Reference_Data/1000Genomes/analysis";
my $NUM_JOBS=10;

my $writer=new SlurmWriter;
my @files=`ls $FASTQ/*.fastq.gz`;
foreach my $file (@files) {
  chomp $file;
  if($file=~/([^\/]+).fastq.gz/) {
    my $id=$1;
    my $outdir="fastqc/$id";
    system("mkdir -p $outdir");
    my $cmd="$FASTQC -o $outdir $file";
    $writer->addCommand($cmd);
  }
}

$writer->writeScripts(10,"slurms2","fastqc","lowmem",$ANALYSIS);
#		      "#SBATCH --mem 1500");


