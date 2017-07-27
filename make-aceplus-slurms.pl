#!/usr/bin/perl
use strict;
use SlurmWriter;

my $MAX_INDIV=1000;
my $JOB_NAME="ACE+";
my $GEUVADIS_ONLY=1;
my $ACEPLUS="/home/bmajoros/ACEPLUS";
#my $PROGRAM="$ACEPLUS/aceplus.pl";
my $PROGRAM="$ACEPLUS/aceplus-multi.pl";
my $GFF_PROGRAM="$ACEPLUS/essex-to-gff-AS2.pl";
my $OUT1="1.aceplus.logreg.essex"; #"1.aceplus.full";
my $OUT2="2.aceplus.logreg.essex"; #"2.aceplus.full";
my $GFF_OUT1="1.aceplus.logreg.gff";
my $GFF_OUT2="2.aceplus.logreg.gff";
my $MODEL="/home/bmajoros/1000G/ACEPLUS/model";
my $MAX_ERRORS=0;
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $REF_FASTA="$COMBINED/ref/1.fasta";
my $SLURM_DIR="$ASSEMBLY/aceplus-slurms";
my $LOCAL_GENES="$ASSEMBLY/local-genes.gff";

my $numIndiv=0;
my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  next unless -e "$COMBINED/$subdir/RNA/junctions.bed";
  my $dir="$COMBINED/$subdir";
#  my $GFF_CMD1="$GFF_PROGRAM  $OUT1  $GFF_OUT1  1";
#  $writer->addCommand("cd $dir ; rm -f $OUT1 ; $PROGRAM  $MODEL  $REF_FASTA  $dir/1.fasta  $LOCAL_GENES  $MAX_ERRORS  $dir/$OUT1 ; $GFF_CMD1");
#  my $GFF_CMD2="$GFF_PROGRAM  $OUT2  $GFF_OUT2  2";
#  $writer->addCommand("cd $dir ; rm -f $OUT2 ; $PROGRAM  $MODEL  $REF_FASTA  $dir/2.fasta  $LOCAL_GENES $MAX_ERRORS  $dir/$OUT2 ; $GFF_CMD2");

  $writer->addCommand("cd $dir ; $PROGRAM  $MODEL  $REF_FASTA  $dir/1.fasta  $LOCAL_GENES  $MAX_ERRORS  $dir/$OUT1");
  $writer->addCommand("cd $dir ; $PROGRAM  $MODEL  $REF_FASTA  $dir/2.fasta  $LOCAL_GENES $MAX_ERRORS  $dir/$OUT2");

  ++$numIndiv;
  if($numIndiv>=$MAX_INDIV) { last }
}
$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,$JOB_NAME,$SLURM_DIR,1000,
			  "#SBATCH --exclude=x2-01-1,x2-01-2,x2-01-3,x2-01-4,x2-02-1,x2-02-2,x2-02-3,x2-02-4,x2-03-1\n");


