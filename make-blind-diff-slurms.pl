#!/usr/bin/perl
use strict;
use SlurmWriter;

my $MEMORY=5000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/blind-diff-slurms";
my $PROGRAM="$THOUSAND/src/blind-diff.pl";
my $PROGRAM="$THOUSAND/src/blind-diff-structure.pl";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";
  #my $outfile="$dir/diff.txt";
  #$slurm->addCommand("$PROGRAM $dir > $outfile");
  $slurm->addCommand("$PROGRAM $dir cryptic-site > $dir/diff-cryptic.txt ; $PROGRAM $dir exon-skipping > $dir/diff-skipping.txt");
}

$slurm->nice(500);
$slurm->mem($MEMORY);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"DIFF","",800);


