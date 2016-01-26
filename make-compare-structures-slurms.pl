#!/usr/bin/perl
use strict;
use SlurmWriter;

my $MEMORY=10000; # was 40000
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SRC="/home/bmajoros/cia";
my $SLURM_DIR="$THOUSAND/assembly/structure-slurms";

my $writer=new SlurmWriter();
my @subdirs=`ls $COMBINED`;
foreach my $ID (@subdirs) {
  chomp $ID;
  next unless $ID=~/HG\d+/ || $ID=~/NA\d+/;
  my $infile1="$COMBINED/$ID/mapped.gff";
  my $infile2="$COMBINED/$ID/RNA/stringtie-reformatted.gff";
  my $outfile="$COMBINED/$ID/RNA/structure-comparison.txt";
  System("rm -f $outfile") if -e $outfile;
  my $cmd="$SRC/compare-transcript-structures.pl $infile1 $infile2 > $outfile";
  $writer->addCommand($cmd);
  $writer->mem($MEMORY);
}
$writer->writeScripts(100,$SLURM_DIR,"struct",$SLURM_DIR);


sub System
{
  my ($cmd)=@_;
  #print "$cmd\n";
  system($cmd);
}


