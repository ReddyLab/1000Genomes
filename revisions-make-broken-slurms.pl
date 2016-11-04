#!/usr/bin/perl
use strict;
use SlurmWriter;

my $JOB_NAME="BROKEN";
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/broken-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  next unless -e "$COMBINED/$subdir/RNA/stringtie.gff";
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("module load python/3.4.1-fasrc01 ; cd $dir ; $THOUSAND/src/revisions-get-broken-sites.py $subdir 1 1.essex > 1.broken-sites");
  $writer->addCommand("module load python/3.4.1-fasrc01 ; cd $dir ; $THOUSAND/src/revisions-get-broken-sites.py $subdir 2 2.essex > 2.broken-sites");
}
$writer->mem(5000);
$writer->setQueue("all,new");
$writer->writeArrayScript($SLURM_DIR,$JOB_NAME,$SLURM_DIR,1000);


