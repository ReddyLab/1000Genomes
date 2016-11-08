#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/new-tophat-validation-slurms";
my $PROGRAM="$THOUSAND/src/revisions-tophat-validation.pl";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";

  $slurm->addCommand("cd $dir; $PROGRAM $subdir 1.gff 1 RNA/junctions.bed ALT 1.blacklist 1.alts-with-nmd 1.readcounts-rev > 1.tophat-validation-rev");
  $slurm->addCommand("cd $dir; $PROGRAM $subdir 2.gff 2 RNA/junctions.bed ALT 2.blacklist 2.alts-with-nmd 2.readcounts-rev > 2.tophat-validation-rev");

  #$slurm->addCommand("cd $dir; $PROGRAM $subdir 1.gff 1 RNA/blind/junctions.bed ALT 1.blacklist 1.alts-with-nmd blind-1.readcounts-rev > blind-1.tophat-validation-rev");
  #$slurm->addCommand("cd $dir; $PROGRAM $subdir 2.gff 2 RNA/blind/junctions.bed ALT 2.blacklist 2.alts-with-nmd blind-2.readcounts-rev > blind-2.tophat-validation-rev");
  #$slurm->addCommand("cd $dir; $PROGRAM $subdir random-1.gff 1 RNA/sim/junctions.bed SIM random-1.blacklist random-1.alts-with-nmd random-1.readcounts-rev > random-1.tophat-validation-rev");
  #$slurm->addCommand("cd $dir; $PROGRAM $subdir random-2.gff 2 RNA/sim/junctions.bed SIM random-2.blacklist random-2.alts-with-nmd random-2.readcounts-rev > random-2.tophat-validation-rev");
}

$slurm->nice(500);
$slurm->mem(3000);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"TOPHAT","",1780);


