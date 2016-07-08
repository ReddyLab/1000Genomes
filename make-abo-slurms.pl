#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/abo-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  $writer->addCommand("cd $dir ; /home/bmajoros/genomics/perl/fasta-grep.pl -f ENSG00000175164.9 1.fasta D > ABO-1.fasta");
  $writer->addCommand("cd $dir ; /home/bmajoros/genomics/perl/fasta-grep.pl -f ENSG00000175164.9 2.fasta D > ABO-2.fasta");
}
$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"GREP",$SLURM_DIR,800);


