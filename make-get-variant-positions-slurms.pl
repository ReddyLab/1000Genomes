#!/usr/bin/perl
use strict;
use SlurmWriter;

my $VCF_DIR="/home/bmajoros/1000G/vcf";
my $THOUSAND="/home/bmajoros/1000G/assembly";
my $SLURM_DIR="$THOUSAND/variant-position-slurms";
my $SRC="$THOUSAND/src";
my $PROGRAM="$SRC/get-variant-positions.pl";
my $OUTDIR="/home/bmajoros/hapmix/data-prep/centimorgans";

my $writer=new SlurmWriter();
my @VCFs=`ls $VCF_DIR`;
foreach my $file (@VCFs) {
  chomp $file;
  next unless $file=~/^ALL\.(chr[^.]+).*vcf\.gz$/;
  my $chr=$1;
  $writer->addCommand("$PROGRAM $VCF_DIR/$file > $OUTDIR/$chr.pos");
}
$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"VCF",$SLURM_DIR,500);


