#!/usr/bin/perl
use strict;
use SlurmWriter;

my $NUM_SCRIPTS=24;
my $SLURM_DIR="/home/bmajoros/1000G/assembly/sort-vcf-slurms";
my $GRCH38="/home/bmajoros/1000G/vcf/GRCh38";

my $writer=new SlurmWriter();
my $DIR="/home/bmajoros/1000G/vcf/GRCh38";
my @files=`ls $DIR/*.vcf.gz`;
foreach my $file (@files) {
  chomp $file;
  next unless($file=~/chr([^\.]+)\.vcf\.gz/);
  my $id=$1;
  my $outfile="chr$id.sorted.vcf.gz";
  my $cmd="setenv TMPDIR /home/bmajoros/1000G/vcf/GRCh38/tmp ; cat $file | bgzip -d | vcf-sort | bgzip > $DIR/$outfile ; tabix $DIR/$outfile";
  #print "$cmd\n";
  $writer->addCommand($cmd);
}

$writer->mem(30000);
$writer->writeScripts($NUM_SCRIPTS,$SLURM_DIR,"SORT",$SLURM_DIR);

