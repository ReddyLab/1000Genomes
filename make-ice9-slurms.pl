#!/usr/bin/perl
use strict;
use SlurmWriter;

my $JOB_NAME="ICE9";
my $GEUVADIS_ONLY=1;
my $PROGRAM="ice9.pl";
my $OUT1="1.ice9";
my $OUT2="2.ice9";
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $MODEL="$THOUSAND/ICE/model9";
my $SLURM_DIR="$ASSEMBLY/ice9-slurms";
my $MAX_ERRORS=0;
my $REF_FASTA="$COMBINED/ref/1.fasta";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  next unless -e "$COMBINED/$subdir/RNA/stringtie.gff";
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; /home/bmajoros/ICE/$PROGRAM  $MODEL  $REF_FASTA  $dir/1.ice9.fasta  /home/bmajoros/1000G/assembly/local-genes.gff  $MAX_ERRORS  $dir/$OUT1");
  $writer->addCommand("cd $dir ; /home/bmajoros/ICE/$PROGRAM  $MODEL  $REF_FASTA  $dir/2.ice9.fasta  /home/bmajoros/1000G/assembly/local-genes.gff  $MAX_ERRORS  $dir/$OUT2");
}
$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"ICE",$SLURM_DIR,500);


