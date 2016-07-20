#!/usr/bin/perl
use strict;
use SlurmWriter;

my $CPUs=8;
my $MEMORY=40000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $RNA_LIST="$THOUSAND/assembly/id-map-parsed.txt";
my $SLURMS="$THOUSAND/assembly/blind-RNA-slurms";
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
  $slurm->addCommand("
cd $dir

module load bowtie2/2.2.4-fasrc01
module load tophat/2.0.13-gcb01

cd RNA
mkdir blind
cd blind

cat ../../1.fasta ../../2.fasta > 1and2.fa

cat ../../1.gff ../../2.gff | grep -v ALT > 1and2.gff

bowtie2-build 1and2.fa 1and2

tophat2 --output-dir $dir/RNA/blind --min-intron-length 30 --num-threads $CPUs --GTF $dir/RNA/blind/1and2.gff 1and2 $FASTQ/$rnaID\_1.fastq.gz $FASTQ/$rnaID\_2.fastq.gz

/data/reddylab/software/stringtie/stringtie-1.2.1.Linux_x86_64/stringtie accepted_hits.bam -G $dir/RNA/blind/1and2.gff -o $dir/RNA/blind/stringtie-blind.gff -p $CPUs

rm *.bt2 accepted_hits.bam unmapped.bam
rm 1and2.fa 1and2.gff

echo \\[done\\]
");
}

$slurm->nice(500);
$slurm->mem($MEMORY);
$slurm->threads($CPUs);
$slurm->setQueue("new,all");
$slurm->writeArrayScript($SLURMS,"BLIND","",800);
