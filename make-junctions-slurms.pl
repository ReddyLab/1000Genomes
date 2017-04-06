#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/junctions-slurms";

my @IDs;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  push @IDs,$subdir;}

my $slurm=new SlurmWriter;
foreach my $ID (@IDs) {
  my $dir="$COMBINED/$ID";
  next unless -e "$dir/RNA/junctions.bed";
  $slurm->addCommand("
cd $dir/RNA2

$THOUSAND/src/gff-to-junctions.py ../1.aceplus.gff > 1.gff.junctions

$THOUSAND/src/gff-to-junctions.py ../2.aceplus.gff > 2.gff.junctions

cat 1.gff.junctions 2.gff.junctions > predicted.junctions

rm ?.gff.junctions

$THOUSAND/src/tophat-to-junctions.py junctions.bed > observed.junctions

/data/reddylab/software/samtools/samtools-1.1/samtools view accepted_hits.bam | /home/bmajoros/1000G/src/count-mapped-reads.pl > readcounts-unfiltered.txt

echo \\[done\\]
");
}

$slurm->nice(500);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"junctions","",1000);
