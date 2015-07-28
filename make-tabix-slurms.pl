#!/usr/bin/perl
use strict;
use SlurmWriter;

#my $SCRATCH="/data/reddylab/bmajoros/scratch";
my $VCF="/data/common/1000_genomes/VCF/20130502/by-population";
my $ANALYSIS="/data/reddylab/Reference_Data/1000Genomes/analysis";
my $REGIONS="/home/bmajoros/ensembl/coding-and-noncoding-genes.bed";
my $NUM_JOBS=60;

my $writer=new SlurmWriter;
my @files=`ls $VCF/*.vcf.gz`;
foreach my $file (@files) {
  chomp $file;
  if($file=~/([^\/]+).vcf.gz/) {
    my $id=$1;
    my $outfile="tabix/$id.vcf.gz";
    my $cmd="tabix -h $file -R $REGIONS | bgzip > $outfile";
    $writer->addCommand($cmd);
  }
}

#$writer->mem(1500);
$writer->nice();
$writer->writeScripts($NUM_JOBS,"slurms-tabix","tabix","lowmem",$ANALYSIS);


