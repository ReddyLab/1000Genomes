#!/usr/bin/perl
use strict;

my $CPUs=8;
my $MEMORY=40000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $RNA_LIST="$THOUSAND/assembly/id-map-parsed.txt";
my $SLURMS="$THOUSAND/assembly/RNA-sim-slurms";
my $FASTQ="$THOUSAND/trim/output";

my @IDs;
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
  if(!$rnaID) { next }
  my $dir="$COMBINED/$ID";
  my $slurm="$SLURMS/$slurmID.slurm";
  open(OUT,">$slurm") || die $slurm;
  print OUT "#!/bin/bash
#
#SBATCH --get-user-env
#SBATCH -J SIM$slurmID
#SBATCH -o $slurmID.output
#SBATCH -e $slurmID.output
#SBATCH -A SIM$slurmID
#SBATCH --mem $MEMORY
#SBATCH --cpus-per-task=$CPUs
#SBATCH -p new
#
module load bowtie2/2.2.4-fasrc01
module load tophat/2.0.13-gcb01

cd $dir/RNA
mkdir -p sim
cd sim

cp ../../random-1.gff ../../random-2.gff > sim.gff

cat ../../1.fasta ../../2.fasta > 1and2.fa

bowtie2-build 1and2.fa 1and2

tophat2 --output-dir $dir/RNA/sim --min-intron-length 30 --num-threads $CPUs --GTF $dir/RNA/sim/sim.gff 1and2 $FASTQ/$rnaID\_1.fastq.gz $FASTQ/$rnaID\_2.fastq.gz

/data/reddylab/software/stringtie/stringtie-1.2.1.Linux_x86_64/stringtie accepted_hits.bam -G $dir/RNA/sim/sim.gff -o stringtie.gff -p $CPUs -C stringtie.coverage -A stringtie.abundance

rm *.bt2 accepted_hits.bam unmapped.bam
rm 1and2.fa sim.gff

";
  close(OUT);
  ++$slurmID;
}

