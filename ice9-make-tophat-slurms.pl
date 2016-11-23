#!/usr/bin/perl
use strict;
use SlurmWriter;

my $MIN_FPKM=10;
my $MIN_READS=1;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/ice9-tophat-validation-slurms";
my $PROGRAM="$THOUSAND/src/ice9-tophat-validation.pl";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";

  $slurm->addCommand("cd $dir; $PROGRAM $MIN_FPKM $MIN_READS $subdir 1.ice9.gff 1 RNA/junctions.bed ALT 1.blacklist 1.ice9-nmd 1.readcounts-ice9 > 1.tophat-validation-ice9");
  $slurm->addCommand("cd $dir; $PROGRAM $MIN_FPKM $MIN_READS $subdir 2.ice9.gff 2 RNA/junctions.bed ALT 2.blacklist 2.ice9-nmd 2.readcounts-ice9 > 2.tophat-validation-ice9");

#  $slurm->addCommand("cd $dir; $PROGRAM $MIN_FPKM $MIN_READS $subdir 1.gff 1 RNA/blind/junctions.bed ALT 1.blacklist 1.alts-with-nmd blind-1.readcounts-rev$MIN_READS > blind-1.tophat-validation-rev$MIN_READS");
#  $slurm->addCommand("cd $dir; $PROGRAM $MIN_FPKM $MIN_READS $subdir 2.gff 2 RNA/blind/junctions.bed ALT 2.blacklist 2.alts-with-nmd blind-2.readcounts-rev$MIN_READS > blind-2.tophat-validation-rev$MIN_READS");

#  $slurm->addCommand("cd $dir; $PROGRAM $MIN_FPKM $MIN_READS $subdir random-1.gff 1 RNA/sim/junctions.bed SIM random-1.blacklist random-1.alts-with-nmd random-1.readcounts-rev$MIN_READS > random-1.tophat-validation-rev$MIN_READS");
#  $slurm->addCommand("cd $dir; $PROGRAM $MIN_FPKM $MIN_READS $subdir random-2.gff 2 RNA/sim/junctions.bed SIM random-2.blacklist random-2.alts-with-nmd random-2.readcounts-rev$MIN_READS > random-2.tophat-validation-rev$MIN_READS");
}

$slurm->nice(500);
$slurm->mem(3000);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"TOPHAT","",1780);


