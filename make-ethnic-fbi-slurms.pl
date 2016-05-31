#!/usr/bin/perl
use strict;
use SlurmWriter;

my $NUM_JOBS=6;
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined-ethnic";
my $REF_FASTA="$COMBINED/ref/1.fasta";
my $SLURM_DIR="$ASSEMBLY/ethnic-fbi-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  my $dir="$COMBINED/$subdir";
  unlink("$dir/1.essex") if -e "$dir/1.essex";
  $writer->addCommand("cd $dir ; /home/bmajoros/FBI/fbi.pl /home/bmajoros/1000G/FBI/model $REF_FASTA $dir/1.fasta /home/bmajoros/1000G/assembly/local-genes.gff $dir/1.essex");
}
$writer->mem(10000);
$writer->setQueue("new,all");
$writer->writeScripts($NUM_JOBS,$SLURM_DIR,"fbi_eth",$SLURM_DIR);



