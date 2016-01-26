#!/usr/bin/perl
use strict;
use SlurmWriter;

my $MEMORY=10000; # was 40000
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SRC="$THOUSAND/src";
my $SLURM_DIR="$THOUSAND/assembly/stringtie-slurms";

my $writer=new SlurmWriter();
my @subdirs=`ls $COMBINED`;
foreach my $ID (@subdirs) {
  chomp $ID;
  next unless $ID=~/HG\d+/ || $ID=~/NA\d+/;
  my $infile="$COMBINED/$ID/RNA/stringtie.gff";
  my $outfile="$COMBINED/$ID/RNA/stringtie-reformatted.gff";
  System("rm -f $outfile") if -e $outfile;
  my $cmd="$SRC/map-stringtie-IDs.pl $infile $outfile";
  $writer->addCommand($cmd);
  $writer->mem($MEMORY);
}
$writer->writeScripts(100,$SLURM_DIR,"ID",$SLURM_DIR);


sub System
{
  my ($cmd)=@_;
  #print "$cmd\n";
  system($cmd);
}


