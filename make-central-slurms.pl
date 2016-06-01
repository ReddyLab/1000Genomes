#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $VCF="$THOUSAND/vcf";
my $MAJOR="$THOUSAND/assembly/combined-ethnic/major";
my $SLURM_DIR="$ASSEMBLY/central-slurms";
my $COMMAND="/home/bmajoros/ethnic/find-central-individual";
my $POPULATIONS="/home/bmajoros/1000G/assembly/populations.txt";
my $PLOIDY=2;

my @VCFs=`ls $VCR`;
my $writer=new SlurmWriter;

foreach my $vcf (@VCFs) {
  chomp $vcf;
  next unless $vcf=~/(chr[^.]+)/;
  my $chr=$1;
  my $outfile="$MAJOR/central.$chr.vcf.gz";
  $writer->addCommand("$CMD $vcf $MAJOR/$chr.vcf.gz $POPULATIONS $PLOIDY $outfile");
}
$writer->writeArrayScript($SLURM_DIR,"CNTR",$SLURM_DIR,500);






