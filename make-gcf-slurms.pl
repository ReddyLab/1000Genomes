#!/usr/bin/perl
use strict;
use SlurmWriter;

#my $QUEUE="lowmem"
my $QUEUE="lowmem";
my $SCRATCH="/data/reddylab/bmajoros/scratch";
my $VCF="/data/common/1000_genomes/VCF/20130502/by-population";
my $PROGRAM="/home/bmajoros/gz/vcf-to-gcf";
my $ANALYSIS="/data/reddylab/Reference_Data/1000Genomes/analysis";
my $REGIONS="/home/bmajoros/ensembl/coding-and-noncoding-genes.bed";
my $NUM_JOBS=100;

my $writer=new SlurmWriter;
my @files=`ls $VCF/*.vcf.gz`;
my $fileNum=1;
foreach my $file (@files) {
  chomp $file;
  if($file=~/([^\/]+).vcf.gz/) {
    my $id=$1;
    my $outfile="gcf/$id.gcf.gz";
    my $tempfile="$SCRATCH/$fileNum.binary";
    ++$fileNum;
    #my $cmd="$PROGRAM -m $tempfile -c -v -f $REGIONS $file $outfile ; rm $tempfile";
    my $cmd="$PROGRAM -m $tempfile -c -v $file $outfile ; rm $tempfile";
    #my $cmd="$PROGRAM -c -v $file $outfile";
    $writer->addCommand($cmd);
  }
}

#$writer->mem(10000);
#$writer->nice();
$writer->writeScripts($NUM_JOBS,"slurms-gcf","gcf",$QUEUE,$ANALYSIS);


