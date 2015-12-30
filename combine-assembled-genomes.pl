#!/usr/bin/perl
use strict;

my $BASEDIR="/data/reddylab/Reference_Data/1000Genomes/analysis/assembly/fasta";
my $OUTDIR="combined";
my @dirs=(0,1,2,3,4,5,6,7,8,9);

my @files=`ls $BASEDIR/0/*-?.fasta`;
foreach my $file (@files) {
  chomp $file;
  $file=~/\/([^\/]+-[12].fasta)/ || die;
  $file=$1;
  my $cmd="cd $BASEDIR ; cat ";
  foreach my $subdir (@dirs) {$cmd.="$subdir/$file "}
  $cmd.="> $OUTDIR/$file";
  System();
}

sub System {
  my ($cmd)=@_;
  print "$cmd\n\n";
  #system($cmd);
}

