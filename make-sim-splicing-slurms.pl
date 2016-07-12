#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $REF_FASTA="$COMBINED/ref/1.fasta";
my $SLURM_DIR="$ASSEMBLY/sim-splicing-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $RNA="$dir/RNA";
  next unless -e $RNA;
  $writer->addCommand("cd $dir ; /home/bmajoros/FBI/fbi-random.pl /home/bmajoros/1000G/FBI/model $REF_FASTA $dir/1.fasta /home/bmajoros/1000G/assembly/local-genes.gff $dir/random-1.essex");
  $writer->addCommand("cd $dir ; /home/bmajoros/FBI/fbi-random.pl /home/bmajoros/1000G/FBI/model $REF_FASTA $dir/2.fasta /home/bmajoros/1000G/assembly/local-genes.gff $dir/random-2.essex");
}
$writer->mem(5000);
$writer->setQueue("new");
$writer->writeArrayScript($SLURM_DIR,"SIM",$SLURM_DIR,500);


