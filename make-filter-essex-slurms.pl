#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/filter-essex-slurms";

my @dirs=`ls $COMBINED`;
my $writer=new SlurmWriter;

foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("/home/bmajoros/ICE/essex-filter.pl $dir/1.essex $dir/1-filtered.essex");
  $writer->addCommand("/home/bmajoros/ICE/essex-filter.pl $dir/2.essex $dir/2-filtered.essex");
}
$writer->setQueue("all");
$writer->writeArrayScript($SLURM_DIR,"FLTR",$SLURM_DIR,700);






