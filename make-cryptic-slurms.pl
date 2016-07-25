#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/cryptic-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("/home/bmajoros/1000G/src/count-cryptic.pl $dir/1-filtered.essex > $dir/cryptic-1.txt");
  $writer->addCommand("/home/bmajoros/1000G/src/count-cryptic.pl $dir/2-filtered.essex > $dir/cryptic-2.txt");
}
#$writer->mem(5000);
$writer->nice(500);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"CRYPTIC",$SLURM_DIR,800);



