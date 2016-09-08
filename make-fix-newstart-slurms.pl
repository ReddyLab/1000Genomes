#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/fix-newstart-slurms";
my $SRC="$THOUSAND/src";
my $PROGRAM="$SRC/fix-newstart-nmd.pl";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  $writer->addCommand("cd $dir ; $PROGRAM 1-fixed.essex $indiv-1.essex ; gzip --best $indiv-1.essex ; mv $indiv-1.essex.gz $ASSEMBLY/upload/all");
  $writer->addCommand("cd $dir ; $PROGRAM 2-fixed.essex $indiv-2.essex ; gzip --best $indiv-2.essex ; mv $indiv-2.essex.gz $ASSEMBLY/upload/all");
}
#$writer->mem(5000);
$writer->setQueue("all");
$writer->writeArrayScript($SLURM_DIR,"FIX",$SLURM_DIR,1200);


