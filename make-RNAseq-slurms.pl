#!/usr/bin/perl
use strict;

my $CPUs=32;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
#my $IDs="$THOUSAND/assembly/Geuvadis-keep.txt";
my $RNA_LIST="$THOUSAND/assembly/id-map-parsed.txt";
my $SLURMS="$THOUSAND/assembly/RNA-slurms";
my $FASTQ="$THOUSAND/trim/output";

my @IDs;
#open(IN,$IDs) || die $IDs;
#while(<IN>) { chomp; push @IDs,$_ }
#close(IN);
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  push @IDs,$subdir;
}

my %rnaHash;
open(IN,$RNA_LIST) || die $RNA_LIST;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields>=2;
  my ($rnaID,$indivID)=@fields;
  $rnaHash{$indivID}=$rnaID;
}
close(IN);

my $slurmID=1;
foreach my $ID (@IDs) {
  my $rnaID=$rnaHash{$ID};
  #die $ID unless $rnaID;
  if(!$rnaID) {
    print "not found: $ID\n";
    next;
  }
  my $dir="$COMBINED/$ID";
  my $slurm="$SLURMS/$slurmID.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH --get-user-env
#SBATCH -J RNA$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A RNA$slurmID
#SBATCH --mem 10000
#SBATCH --cpus-per-task=$CPUs
#
cd $dir

rm -rf RNA

mkdir RNA

cd RNA

cat ../1.fasta ../2.fasta > 1and2.fa

bowtie2-build 1and2.fa 1and2

tophat2 --output-dir $dir/RNA --min-intron-length 30 --num-threads $CPUs --GTF $dir/reformatted.gff 1and2 $FASTQ/$rnaID\_1.fastq.gz $FASTQ/$rnaID\_2.fastq.gz

/data/reddylab/software/stringtie/stringtie-1.2.1.Linux_x86_64/stringtie accepted_hits.bam -G $dir/reformatted.gff -o stringtie.gff -p 1 -C stringtie.coverage -A stringtie.abundance
";
  close(OUT);
  ++$slurmID;
}

