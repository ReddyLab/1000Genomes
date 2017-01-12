#!/usr/bin/perl
use strict;
use SlurmWriter;

my $MAX_INDIV=1;
my $JOB_NAME="ACE+";
my $GEUVADIS_ONLY=1;
my $PROGRAM="ace.pl";
my $OUT1="ace1-new.essex"; # "1.essex"
my $OUT2="ace2-new.essex"; # "2.essex"
my $MODEL="/home/bmajoros/1000G/ACE/model";
my $MAX_ERRORS=0;
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $REF_FASTA="$COMBINED/ref/1.fasta";
my $SLURM_DIR="$ASSEMBLY/aceplus-slurms";

my $numIndiv=0;
my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  next unless -e "$COMBINED/$subdir/RNA/stringtie.gff";
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; /home/bmajoros/ACEPLUS/$PROGRAM  $MODEL  $REF_FASTA  $dir/1.fasta  /home/bmajoros/1000G/assembly/local-genes.gff  $MAX_ERRORS  $dir/$OUT1");
  $writer->addCommand("cd $dir ; /home/bmajoros/ACEPLUS/$PROGRAM  $MODEL  $REF_FASTA  $dir/2.fasta  /home/bmajoros/1000G/assembly/local-genes.gff  $MAX_ERRORS  $dir/$OUT2");
  ++$numIndiv;
  if($numIndiv>=$MAX_INDIV) { last }
}
$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,$JOB_NAME,$SLURM_DIR,500);


