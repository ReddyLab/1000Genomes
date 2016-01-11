#!/usr/bin/perl
use strict;

my $BASEDIR="/home/bmajoros/1000G/assembly/combined";
my $GFF="/home/bmajoros/1000G/assembly/local-genes.gff";
my $REF="$BASEDIR/ref";
my $SRC="/home/bmajoros/1000G/src";

my @subdirs=`ls $BASEDIR`;
foreach my $dir (@subdirs) {
  next if $dir eq "ref";
  my $outfile="$BASEDIR/$dir/mapped.gff";
  System("rm $outfile") if -e $outfile;
  System("$SRC/map-anno-to-haplotypes.pl $GFF $REF $BASEDIR/$dir");
}


sub System
{
  my ($cmd)=@_;
  #print "$cmd\n";
  system($cmd);
}


