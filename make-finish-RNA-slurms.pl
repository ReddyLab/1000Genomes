#!/usr/bin/perl
use strict;
use SlurmWriter;

my $CPUs=8;
my $MEMORY=40000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $RNA_LIST="$THOUSAND/assembly/id-map-parsed.txt";
my $SLURMS="$THOUSAND/assembly/finish-RNA-slurms";
my $FASTQ="$THOUSAND/trim/output";

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

my $slurm=new SlurmWriter;
foreach my $ID (@IDs) {
  my $rnaID=$rnaHash{$ID};
  next unless $rnaID;
  my $dir="$COMBINED/$ID";
  next unless -e "$dir/RNA2/sorted.bam.bam"
  $slurm->addCommand("
cd $dir

module load python/2.7.11-fasrc01

cd RNA2

rm *.bt2
rm 1and2.fa 1and2.gff

mv sorted.bam.bam sorted.bam

rm accepted_hits.bam unmapped.bam
rm -r logs

/data/reddylab/software/samtools/samtools-1.1/samtools mpileup sorted.bam -o pileup.txt

#rm sorted.bam

rm -f pileup.txt.gz
cat pileup.txt | cut -f1,2,4 | gzip > pileup.txt.gz

rm pileup.txt

echo \\[done\\]
");
}

$slurm->nice(500);
$slurm->mem($MEMORY);
$slurm->threads($CPUs);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"RNA","",1000);
