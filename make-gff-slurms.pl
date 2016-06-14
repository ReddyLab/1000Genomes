#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/gff-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("/home/bmajoros/FBI/essex-to-gff.pl $dir/1-filtered.essex  $dir/1.gff");
  $writer->addCommand("/home/bmajoros/FBI/essex-to-gff.pl $dir/2-filtered.essex  $dir/2.gff");
}
#$writer->mem(5000);
$writer->setQueue("all");
#$writer->nice(500);
#$writer->writeScripts($NUM_JOBS,$SLURM_DIR,"FBI",$SLURM_DIR);
$writer->writeArrayScript($SLURM_DIR,"GFF",$SLURM_DIR,500);


