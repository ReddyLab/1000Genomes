#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/inactivation-slurms";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $slurm->addCommand("$THOUSAND/src/essex-get-inactive.pl $dir/1-filtered.essex > $dir/1-inactivated-withsplicing2.txt");
  $slurm->addCommand("$THOUSAND/src/essex-get-inactive.pl $dir/2-filtered.essex > $dir/2-inactivated-withsplicing2.txt");
}
$slurm->setQueue("new,all");
$slurm->nice(500);
$slurm->writeArrayScript($SLURM_DIR,"LOF",$SLURM_DIR,800);


