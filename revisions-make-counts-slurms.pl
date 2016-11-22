#!/usr/bin/perl
use strict;
use SlurmWriter;

my $JOB_NAME="COUNTS1";
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/broken-counts-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  next unless -e "$COMBINED/$subdir/RNA/stringtie.gff";
  my $dir="$COMBINED/$subdir";
#  $writer->addCommand("module load python/3.4.1-fasrc01 ; cd $dir ; $THOUSAND/src/revisions-get-junctions-broken.py 1.broken-sites RNA/junctions.bed 1.gff RNA/readcounts.txt > 1.broken-sites-counts");
#  $writer->addCommand("module load python/3.4.1-fasrc01 ; cd $dir ; $THOUSAND/src/revisions-get-junctions-broken.py 2.broken-sites RNA/junctions.bed 2.gff RNA/readcounts.txt > 2.broken-sites-counts");
  $writer->addCommand("module load python/3.4.1-fasrc01 ; cd $dir ; $THOUSAND/src/revisions-get-junctions-broken.py 1.broken-sites RNA/junctions.bed 1.gff RNA2/readcounts-unfiltered.txt > 1.broken-sites-counts-unfiltered");
  $writer->addCommand("module load python/3.4.1-fasrc01 ; cd $dir ; $THOUSAND/src/revisions-get-junctions-broken.py 2.broken-sites RNA/junctions.bed 2.gff RNA2/readcounts-unfiltered.txt > 2.broken-sites-counts-unfiltered");
}
$writer->mem(5000);
$writer->setQueue("all,new");
$writer->writeArrayScript($SLURM_DIR,$JOB_NAME,$SLURM_DIR,1000);


