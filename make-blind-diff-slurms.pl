#!/usr/bin/perl
use strict;
use SlurmWriter;

my $MEMORY=5000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/blind-diff-slurms";
my $PROGRAM="$THOUSAND/src/blind-diff.pl";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";
  $slurm->addCommand("$PROGRAM $dir > $dir/diff.txt");
}

$slurm->nice(500);
$slurm->mem($MEMORY);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"DIFF","",800);


