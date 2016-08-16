#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/classify-crypskip-slurms";
my $PROGRAM="$THOUSAND/src/classify-alt-crypskip.pl";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";
  $slurm->addCommand("$PROGRAM 1 $dir/1-filtered.essex > $dir/1.crypskip");
  $slurm->addCommand("$PROGRAM 2 $dir/2-filtered.essex > $dir/2.crypskip");
}

$slurm->nice(500);
#$slurm->mem(3000);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"CRYPSKIP","",1000);


