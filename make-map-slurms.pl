#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $BASEDIR="$THOUSAND/assembly/combined";
my $GFF="$THOUSAND/assembly/local-genes.gff";
my $REF="$BASEDIR/ref";
my $SRC="$THOUSAND/src";
my $SLURM_DIR="$THOUSAND/assembly/map-slurms";

my $writer=new SlurmWriter();
my @subdirs=`ls $BASEDIR`;
foreach my $ID (@subdirs) {
  chomp $ref;
  next if $ID eq "ref";
  my $outfile="$BASEDIR/$ID/mapped.gff";
  System("rm $outfile") if -e $outfile;
  my $cmd="$SRC/map-anno-to-haplotypes.pl $GFF $REF $BASEDIR/$ID";
  $writer->addCommand($cmd);
  $writer->mem(4000);
}
$writer->writeScripts(400,$SLURM_DIR,$ID,"$BASEDIR/$ID");


sub System
{
  my ($cmd)=@_;
  #print "$cmd\n";
  system($cmd);
}


