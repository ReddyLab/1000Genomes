#!/usr/bin/perl
use strict;
use EssexParser;

my $BASE="/home/bmajoros/1000G/assembly/DMD";
my $INDIR="$BASE/out";

my @files=`ls $INDIR/*.essex`;
foreach my $file (@files) {
  chomp; $file=~/(\S+)\.essex/ || die $file;
  my $parser=new EssexParser("$INDIR/$file");
  my $root=$parser->nextElem();
  $parser->close();
  my $status=$root->pathQuery("report/status");
  die "no status" unless $status;
  
}

