#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/indel-null-slurms";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $slurm->addCommand("/home/bmajoros/1000G/src/compensatory-indels-null2.pl $subdir $dir/1-filtered.essex > $dir/1-indels-null.txt");
  $slurm->addCommand("/home/bmajoros/1000G/src/compensatory-indels-null2.pl $subdir $dir/2-filtered.essex > $dir/2-indels-null.txt");
}
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURM_DIR,"NULL",$SLURM_DIR,500);



