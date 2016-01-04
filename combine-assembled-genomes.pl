#!/usr/bin/perl
use strict;

my $BASEDIR="/data/reddylab/Reference_Data/1000Genomes/analysis/assembly/fasta";
my $OUTDIR="/data/reddylab/Reference_Data/1000Genomes/analysis/assembly/combined";
my @dirs=(0,1,2,3,4,5,6,7,8,9);

my @files=`ls $BASEDIR/0/*-1.fasta`;
foreach my $file (@files) {
  chomp $file;
  $file=~/\/([^\/]+)-1.fasta/ || die;
  my $ID=$1;
  System("cd $OUTDIR ; mkdir $ID");
  my $outdir="$OUTDIR/$ID";
  my $cmd="cd $BASEDIR ; cat ";
  foreach my $subdir (@dirs) {$cmd.="$subdir/$ID-1.fasta "}
  $cmd.="> $outdir/1.fasta";
  System($cmd);
  my $cmd="cd $BASEDIR ; cat ";
  foreach my $subdir (@dirs) {$cmd.="$subdir/$ID-2.fasta "}
  $cmd.="> $outdir/2.fasta";
  System($cmd);
}

sub System {
  my ($cmd)=@_;
  #print "$cmd\n\n";
  system($cmd);
}

