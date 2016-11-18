#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/ice9-subset-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/junctions.bed";
  $writer->addCommand("$THOUSAND/src/ice9-subset-fasta.py $dir/1.fasta $dir/1.ice9.gff $dir/1.ice9.fasta");
  $writer->addCommand("$THOUSAND/src/ice9-subset-fasta.py $dir/2.fasta $dir/2.ice9.gff $dir/2.ice9.fasta");
}
$writer->mem(5000);
$writer->setQueue("new,all");
$writer->nice(500);
$writer->writeArrayScript($SLURM_DIR,"GFF",$SLURM_DIR,1000);


