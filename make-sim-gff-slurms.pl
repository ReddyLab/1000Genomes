#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/sim-gff-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA";
  $writer->addCommand("/home/bmajoros/FBI/essex-to-gff-AS.pl $dir/random-1.essex  $dir/random-1.gff 1");
  $writer->addCommand("/home/bmajoros/FBI/essex-to-gff-AS.pl $dir/random-2.essex  $dir/random-2.gff 2");
}
#$writer->mem(5000);
$writer->setQueue("new");
#$writer->nice(500);
#$writer->writeScripts($NUM_JOBS,$SLURM_DIR,"FBI",$SLURM_DIR);
$writer->writeArrayScript($SLURM_DIR,"GFF",$SLURM_DIR,1000);


