#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/broken-sites-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("/home/bmajoros/1000G/src/genes-with-broken-splice-sites.pl $subdir 1 $dir/1-filtered.essex $dir/1.broken");
  $writer->addCommand("/home/bmajoros/1000G/src/genes-with-broken-splice-sites.pl $subdir 2 $dir/2-filtered.essex $dir/2.broken");
}
#$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"BRK",$SLURM_DIR,500);

