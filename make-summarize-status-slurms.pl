#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/summarize-status-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; /home/bmajoros/1000G/src/summarize-status.pl 1.essex.old > 1-status.txt");
  $writer->addCommand("cd $dir ; /home/bmajoros/1000G/src/summarize-status.pl 2.essex.old > 2-status.txt");
}
#$writer->mem(5000);
$writer->setQueue("new");
$writer->nice(500);
#$writer->writeScripts($NUM_JOBS,$SLURM_DIR,"ICE",$SLURM_DIR);
$writer->writeArrayScript($SLURM_DIR,"STAT",$SLURM_DIR,200);


