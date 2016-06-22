#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/tabulate-rna-slurms";

my $slurm=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  my $gff="$dir/RNA/stringtie.gff";
  next unless -e $gff;
  $slurm->addCommand("/home/bmajoros/1000G/src/tabulate-rna.pl $gff > $dir/RNA/tab.txt");
}
$slurm->mem(5000);
$slurm->setQueue("new,all");
#   $slurm->nice(); # turns on "nice" (sets it to 100 by default)
$slurm->writeArrayScript($SLURM_DIR,"EXPR",$SLURM_DIR,500);


