#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined-ethnic";
my $SLURM_DIR="$ASSEMBLY/slurms/ethnic-vcf-slurms";
my $VCF="/home/bmajoros/1000G/vcf";
my $PROGRAM="/home/bmajoros/FBI/vcf-population";
my $POPULATIONS="$ASSEMBLY/populations.txt";

my $writer=new SlurmWriter;

my @VCFs=`ls $VCF/*.vcf.gz`;
foreach my $vcf (@VCFs) {
  chomp $vcf;
  $vcf=~/ALL\.([^\.]+)\./ || die $vcf;
  my $chr=$1;
  $writer->addCommand("$PROGRAM $vcf $POPULATIONS $COMBINED/major/$chr.vcf");
}
$writer->writeArrayScript($SLURM_DIR,"ETH",$SLURM_DIR,500);






