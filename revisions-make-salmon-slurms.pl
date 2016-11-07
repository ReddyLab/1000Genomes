#!/usr/bin/perl
use strict;
use SlurmWriter;

# Define some globals
my $JOB_NAME="SALMON";
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/salmon-slurms";
my $RNA_LIST="$THOUSAND/assembly/id-map-parsed.txt";
my $FASTQ="$THOUSAND/trim/output";
my $SRC="$THOUSAND/src";
my $SOFTWARE="/home/bmajoros/software";
my $SALMON="$SOFTWARE/Salmon-0.7.2_linux_x86_64/bin/salmon";
my $KALLISTO="$SOFTWARE/kallisto_linux-v0.43.0/kallisto";
my $THREADS=32;

# Get list of FASTQ files
my @IDs;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  push @IDs,$subdir;}
my %rnaHash;
open(IN,$RNA_LIST) || die $RNA_LIST;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields>=2;
  my ($rnaID,$indivID)=@fields;
  $rnaHash{$indivID}=$rnaID;}
close(IN);

# Write SLURM scripts
my $writer=new SlurmWriter();
foreach my $indiv (@IDs) {
  my $rnaID=$rnaHash{$indiv};
  next unless $rnaID;
  my $dir="$COMBINED/$indiv";
  $writer->addCommand("
module load python/3.4.1-fasrc01
cd $dir
mkdir -p salmon
cd salmon
cat $dir/[12].fasta > 1and2.fa
cat $dir/[12].gff > 1and2.gff
$SRC/get-transcripts.py 1and2.fa 1and2.gff transcripts.fa
rm 1and2.fa 1and2.gff

$SALMON index -t transcripts.fa -i salmonindex
$SALMON quant -l A -o salmonoutput -i salmonindex -1 $FASTQ/$rnaID\_1.fastq.gz -2 $FASTQ/$rnaID\_2.fastq.gz -p $THREADS

$KALLISTO index -i kallistoindex transcripts.fa
$KALLISTO quant -i kallistoindex -o kallistooutput $FASTQ/$rnaID\_1.fastq.gz $FASTQ/$rnaID\_2.fastq.gz -t $THREADS

");
}
$writer->mem(50000);
$writer->setQueue("new,all");
$writer->threads($THREADS);
$writer->writeArrayScript($SLURM_DIR,$JOB_NAME,$SLURM_DIR,1000);


