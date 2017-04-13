#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/fasta-length-slurms";

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
cd $dir

fasta-seq-lengths.pl 1.fasta > 1.lengths
fasta-seq-lengths.pl 2.fasta > 2.lengths

echo \\[done\\]
");
}

$slurm->nice(500);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"LENGTH","",1000);

