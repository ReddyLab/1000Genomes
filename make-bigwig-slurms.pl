#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/bigwig-slurms";
my $PROGRAM="$THOUSAND/src/pileup-to-bigwig.py";

my @IDs;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  push @IDs,$subdir;}

my $slurm=new SlurmWriter;
foreach my $ID (@IDs) {
  my $dir="$COMBINED/$ID";
  next unless -e "$dir/RNA2/pileup.txt.gz";
  $slurm->addCommand("
cd $dir/RNA2

$PROGRAM pileup.txt.gz ../1.lengths ../2.lengths pileup.bigwig

echo \\[done\\]
");
}

$slurm->nice(500);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"BIGWIG","",1000);

