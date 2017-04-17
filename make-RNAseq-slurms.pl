#!/usr/bin/perl
use strict;
use SlurmWriter;

my $CPUs=8;
my $MEMORY=40000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $RNA_LIST="$THOUSAND/assembly/id-map-parsed.txt";
my $SLURMS="$THOUSAND/assembly/RNA-slurms";
my $FASTQ="$THOUSAND/trim/output";
my $OUTDIR="RNA3";

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
  $slurm->addCommand("
cd $dir

module load bowtie2/2.2.4-fasrc01
module load tophat/2.0.13-gcb01
module load python/2.7.11-fasrc01
module load samtools/1.3.1-gcb01

rm -rf $OUTDIR
mkdir -p $OUTDIR
cd $OUTDIR

cat ../1.fasta ../2.fasta > 1and2.fa

cat ../1.aceplus.gff ../2.aceplus.gff > 1and2.gff

bowtie2-build 1and2.fa 1and2

tophat2 --output-dir $dir/$OUTDIR --min-intron-length 30 --num-threads $CPUs --GTF $dir/$OUTDIR/1and2.gff 1and2 $FASTQ/$rnaID\_1.fastq.gz $FASTQ/$rnaID\_2.fastq.gz

rm *.bt2
rm 1and2.fa 1and2.gff

samtools sort accepted_hits.bam -o sorted.bam

rm accepted_hits.bam unmapped.bam
rm -r logs

samtools depth sorted.bam | gzip --best > depth.txt.gz

rm sorted.bam

echo \\[done\\]
");
}

$slurm->nice(500);
$slurm->mem($MEMORY);
$slurm->threads($CPUs);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"RNA","",1000);
