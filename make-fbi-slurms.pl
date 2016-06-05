#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $REF_FASTA="$COMBINED/ref/1.fasta";
my $SLURM_DIR="$ASSEMBLY/fbi-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; /home/bmajoros/FBI/fbi.pl /home/bmajoros/1000G/FBI/model $REF_FASTA $dir/1.fasta /home/bmajoros/1000G/assembly/local-genes.gff $dir/1.essex");
  $writer->addCommand("cd $dir ; /home/bmajoros/FBI/fbi.pl /home/bmajoros/1000G/FBI/model $REF_FASTA $dir/2.fasta /home/bmajoros/1000G/assembly/local-genes.gff $dir/2.essex");
}
$writer->mem(5000);
$writer->setQueue("all");
#$writer->writeScripts($NUM_JOBS,$SLURM_DIR,"FBI",$SLURM_DIR);
$writer->writeArrayScript($SLURM_DIR,"FBI",$SLURM_DIR,500);

#my @files=`ls $SLURM_DIR`;
#foreach my $file (@files) {
#  chomp $file;
#  next unless $file=~/(\d+).slurm/;
#  my $id=$1;
#  my $batch;
#  if($id<=500)     { $batch=1 }
#  elsif($id<=1000) { $batch=2 }
#  elsif($id<=1500) { $batch=3 }
#  elsif($id<=2000) { $batch=4 }
#  else             { $batch=5 }
#  system("mv $SLURM_DIR/$file $SLURM_DIR/$batch");
#}

