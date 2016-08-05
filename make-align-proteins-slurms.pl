#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/align-proteins-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("/home/bmajoros/1000G/src/align-proteins.pl $dir/1-filtered.essex > $dir/1-substitutions.txt");
  $writer->addCommand("/home/bmajoros/1000G/src/align-proteins.pl $dir/2-filtered.essex > $dir/2-substitutions.txt");
}
#$writer->mem(5000);
$writer->setQueue("all");
#$writer->nice(500);
#$writer->writeScripts($NUM_JOBS,$SLURM_DIR,"ICE",$SLURM_DIR);
$writer->writeArrayScript($SLURM_DIR,"ALIGN",$SLURM_DIR,1000);


