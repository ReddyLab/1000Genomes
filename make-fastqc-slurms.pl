#!/usr/bin/perl
use strict;

my $FASTQ="/data/common/1000_genomes/RNA/fastq";
my $FASTQC="/home/bmajoros/software/fastqc/FastQC/fastqc";
my $ANALYSIS="/data/reddylab/Reference_Data/1000Genomes/analysis";
my $NUM_JOBS=10;

my @commands;
my @files=`ls $FASTQ/*.fastq.gz`;
foreach my $file (@files) {
  chomp $file;
  if($file=~/([^\/]+).fastq.gz/) {
    my $id=$1;
    my $outdir="fastqc/$id";
    system("mkdir -p $outdir");
    my $cmd="$FASTQC -o $outdir $file";
    push @commands,$cmd;
  }
}

system("rm -r slurm ; mkdir slurm");
my $numCommands=@commands;
my $commandsPerJob=int($numCommands/$NUM_JOBS);
for(my $i=0 ; $i<$NUM_JOBS ; ++$i) {
  my $begin=$i*$commandsPerJob;
  my $end=($i+1)*$commandsPerJob;
  if($i==$NUM_JOBS-1) { $end=$numCommands }
  my $filename="slurm/fastqc$i.slurm";
  open(OUT,">$filename") || die $filename;
  print OUT "#!/bin/bash
#
#SBATCH -p lowmem
#SBATCH -J fastqc$i
#SBATCH -o fastqc$i.mpirun
#SBATCH -e fastqc$i.mpirun
#SBATCH -A fastqc$i
#
cd $ANALYSIS
";
  for(my $j=$begin ; $j<$end ; ++$j) {
    my $command=$commands[$j];
    print OUT "$command\n";
  }
  close(OUT);
}


