#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/structure-change-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("$THOUSAND/src/structure-changes.pl $dir/1-filtered.essex $dir/1.structure-changes $subdir 1");
  $writer->addCommand("$THOUSAND/src/structure-changes.pl $dir/2-filtered.essex $dir/2.structure-changes $subdir 2");
}
#$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"STRUCT",$SLURM_DIR,500);

