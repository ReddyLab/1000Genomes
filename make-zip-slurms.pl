#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/zip-slurms";
my $SRC="$THOUSAND/src";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  $writer->addCommand("cd $dir ; cat 1.essex | gzip --best > $ASSEMBLY/upload/all/$indiv-1.essex.gz");
  $writer->addCommand("cd $dir ; cat 2.essex | gzip --best > $ASSEMBLY/upload/all/$indiv-2.essex.gz");
}
#$writer->mem(5000);
$writer->setQueue("all");
$writer->writeArrayScript($SLURM_DIR,"ZIP",$SLURM_DIR,1200);


