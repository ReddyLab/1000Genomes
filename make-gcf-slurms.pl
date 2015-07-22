#!/usr/bin/perl
use strict;
use SlurmWriter;

my $VCF="/data/common/1000_genomes/VCF/20130502/by-population";
my $PROGRAM="/home/bmajoros/gz/vcf-to-gcf";
my $ANALYSIS="/data/reddylab/Reference_Data/1000Genomes/analysis";
my $REGIONS="/home/bmajoros/ensembl/coding-and-noncoding-genes.bed";
my $NUM_JOBS=10;

my $writer=new SlurmWriter;
my @files=`ls $VCF/*.vcf.gz`;
foreach my $file (@files) {
  chomp $file;
  if($file=~/([^\/]+).vcf.gz/) {
    my $id=$1;
    my $outfile="gcf/$id.gcf";
    my $cmd="$PROGRAM -c -v -f $REGIONS $file $outfile";
    $writer->addCommand($cmd);
  }
}

$writer->writeScripts(10,"slurms-gcf","gcf","lowmem",$ANALYSIS);


