#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/get-uORF-slurms";
my $SRC="$THOUSAND/src";
my $PROGRAM="$SRC/get-uORFs.pl";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; $PROGRAM $subdir 1 1-filtered-fixed.essex > 1.uORFs");
  $writer->addCommand("cd $dir ; $PROGRAM $subdir 2 2-filtered-fixed.essex > 2.uORFs");
}
#$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"uORF",$SLURM_DIR,800);


