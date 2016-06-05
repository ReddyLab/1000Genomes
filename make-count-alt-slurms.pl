#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my VCF="$THOUSAND/vcf";
my $SLURM_DIR="$THOUSAND/assembly/count-alt-slurms";
my $POPS="/home/bmajoros/1000G/assembly/populations.txt";
my $CMD="/home/bmajoros/ethnic/count-alt-alleles";

my $writer=new SlurmWriter();
my @FILES=`ls $VCF`;
foreach my $file (@FILES) {
  chomp $file;
  $writer->addCommand("$CMD $VCF/$file $POPS");
}
#$writer->mem(5000);
$writer->setQueue("new");
$writer->writeArrayScript($SLURM_DIR,"VCF",$SLURM_DIR);

