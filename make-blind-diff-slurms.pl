#!/usr/bin/perl
use strict;
use SlurmWriter;

my $MEMORY=5000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/new-blind-diff-slurms";
#my $PROGRAM="$THOUSAND/src/blind-diff.pl";
my $PROGRAM="$THOUSAND/src/revisions-blind-diff-structure.pl";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";
  $slurm->addCommand("$PROGRAM $dir cryptic-site > $dir/diff-cryptic.txt-rev ; $PROGRAM $dir exon-skipping > $dir/diff-skipping.txt-rev");
}

$slurm->nice(500);
$slurm->mem($MEMORY);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"DIFF","",800);


