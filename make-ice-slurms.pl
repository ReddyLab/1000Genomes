#!/usr/bin/perl
use strict;
use SlurmWriter;

# UNCOMMENT THESE TO RUN ORIGINAL ICE:
#my $JOB_NAME="ICE";
#my $GEUVADIS_ONLY=0;
#my $PROGRAM="ice.pl";
#my $OUT1="1.essex";
#my $OUT2="2.essex";
#my $model="/home/bmajoros/1000G/ICE/model";

# UNCOMMENT THESE TO RUN ICE9:
my $JOB_NAME="ICE9";
my $GEUVADIS_ONLY=1;
my $PROGRAM="ice9.pl";
my $OUT1="1.ice9";
my $OUT2="2.ice9";
my $MODEL="/home/bmajoros/1000G/ICE/model9";

# COMMON DEFINITIONS:
my $MAX_ERRORS=0;
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $REF_FASTA="$COMBINED/ref/1.fasta";
my $SLURM_DIR="$ASSEMBLY/ice-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  next unless -e "$COMBINED/$subdir/RNA/stringtie.gff";
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; /home/bmajoros/ICE/$PROGRAM  $MODEL  $REF_FASTA  $dir/1.fasta  /home/bmajoros/1000G/assembly/local-genes.gff  $MAX_ERRORS  $dir/$OUT1");
  $writer->addCommand("cd $dir ; /home/bmajoros/ICE/$PROGRAM  $MODEL  $REF_FASTA  $dir/2.fasta  /home/bmajoros/1000G/assembly/local-genes.gff  $MAX_ERRORS  $dir/$OUT2");
}
$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"ICE",$SLURM_DIR,500);


