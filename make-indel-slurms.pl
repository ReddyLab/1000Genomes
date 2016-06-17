#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/indel-slurms";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $slurm->addCommand("/home/bmajoros/1000G/src/compensatory-indels2.pl $subdir $dir/1.essex > $dir/1-indels.txt");
  $slurm->addCommand("/home/bmajoros/1000G/src/compensatory-indels2.pl $subdir $dir/2.essex > $dir/2-indels.txt");
}
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURM_DIR,"INDEL",$SLURM_DIR,500);



