#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/fix-upstream-slurms";
my $PROGRAM="$THOUSAND/src/fix-upstream-start-strand.pl";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; $PROGRAM 1.essex > 1-fixed.essex");
  $writer->addCommand("cd $dir ; $PROGRAM 2.essex > 1-fixed.essex");
  $writer->addCommand("cd $dir ; $PROGRAM 1-filtered.essex > 1-filtered-fixed.essex");
  $writer->addCommand("cd $dir ; $PROGRAM 2-filtered.essex > 2-filtered-fixed.essex");
}
#$writer->mem(5000);
$writer->setQueue("new,all");
$writer->nice(500);
$writer->writeArrayScript($SLURM_DIR,"FIX",$SLURM_DIR,800);


