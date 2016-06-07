#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined-ethnic";
my $SLURM_DIR="$ASSEMBLY/ethnic-inactivation-slurms";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/1-filtered.essex";
  $slurm->addCommand("$THOUSAND/src/essex-get-inactive.pl $dir/1-filtered.essex > $dir/1-inactivated.txt");
}
$slurm->setQueue("new");
$slurm->nice(500);
$slurm->writeArrayScript($SLURM_DIR,"eLOF",$SLURM_DIR,200);


