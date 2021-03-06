#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/summary-stats-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("$THOUSAND/src/basic-summary-stats.pl $dir/1.essex > $dir/1.summary-stats");
  $writer->addCommand("$THOUSAND/src/basic-summary-stats.pl $dir/2.essex > $dir/2.summary-stats");
}
#$writer->mem(5000);
$writer->setQueue("all");
$writer->writeArrayScript($SLURM_DIR,"STATS",$SLURM_DIR,500);



