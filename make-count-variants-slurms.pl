#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/count-variants-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; /home/bmajoros/1000G/src/count-variants.pl 1-filtered.essex > 1-variant-counts.txt");
  $writer->addCommand("cd $dir ; /home/bmajoros/1000G/src/count-variants.pl 2-filtered.essex > 2-variant-counts.txt");
}
#$writer->mem(5000);
$writer->setQueue("all");
#$writer->nice(500);
#$writer->writeScripts($NUM_JOBS,$SLURM_DIR,"FBI",$SLURM_DIR);
$writer->writeArrayScript($SLURM_DIR,"VRNT",$SLURM_DIR,800);


