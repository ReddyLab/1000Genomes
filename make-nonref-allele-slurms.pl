#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $SLURM_DIR="$ASSEMBLY/nonref-allele-slurms";
my $VCF="$THOUSAND/vcf";
my $PROGRAM="$THOUSAND/src/get-nonref-allele-counts.pl";
my $OUTDIR="$ASSEMBLY/allele-counts";

my $writer=new SlurmWriter();
my @VCF=`ls $VCF`;
foreach my $file (@VCF) {
  chomp $file;
  next unless $file=~/ALL\.chr([^\.]+)\..*vcf.gz$/;
  my $chr=$1;
  next if $chr eq "X" || $chr eq "Y";
  my $path="$VCF/$file";
  my $outfile="$OUTDIR/chr$chr.txt";
  $writer->addCommand("$PROGRAM $path > $outfile");
}
$writer->mem(5000);
$writer->setQueue("all");
$writer->writeArrayScript($SLURM_DIR,"VCF",$SLURM_DIR,500);


