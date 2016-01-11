#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $BASEDIR="$THOUSAND/assembly/combined";
my $GFF="$THOUSAND/assembly/local-genes.gff";
my $REF="$BASEDIR/ref";
my $SRC="$THOUSAND/src";
my $SLURM_DIR="$THOUSAND/assembly/map-slurms";

my $writer=new SlurmWriter();
my @subdirs=`ls $BASEDIR`;
foreach my $ID (@subdirs) {
  chomp $ID;
  next if $ID eq "ref";
  my $outfile="$BASEDIR/$ID/mapped.gff";
  System("rm $outfile") if -e $outfile;
  my $cmd="$SRC/map-anno-to-haplotypes.pl $GFF $REF $BASEDIR/$ID";
  $writer->addCommand($cmd);
  $writer->mem(40000);
}
$writer->writeScripts(200,$SLURM_DIR,"map",$SLURM_DIR);


sub System
{
  my ($cmd)=@_;
  #print "$cmd\n";
  system($cmd);
}


