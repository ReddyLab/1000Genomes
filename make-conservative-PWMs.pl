#!/usr/bin/perl
use strict;

#my $FP_RATE=0.20;
my $SENSITIVITY=0.80;
my $HOME="/home/bmajoros";
my $RSVP="$HOME/RSVP/isochores";
my $MODELS="$HOME/1000G/ICE/model";
my $OUTDIR="$MODELS/conservative";
my $ICE="$HOME/ICE";
my $SCORER="$ICE/apply-signal-sensor";
my @ISOCHORES=("0-43","43-51","51-57","57-100");

process("donors");
process("acceptors");

#=====================================================================
sub process {
  my ($type)=@_;
  foreach my $isochore (@ISOCHORES) {
    #my $fasta="$RSVP/iso$isochore/non-$type$isochore.fasta";
    my $fasta="$RSVP/iso$isochore/$type$isochore.fasta";
    my $model="$MODELS/$type$isochore.model";

    # Get the scores of the sites
    my $scores=getScores("$SCORER -C $model $type $fasta");
    @$scores=sort {$a <=> $b} @$scores;
    my $N=@$scores;

    # Pick a cutoff
    #my $index=int($N*(1-$FP_RATE))+1;
    my $index=int($N*(1-$SENSITIVITY))+1;
    my $cutoff=$scores->[$index];
    print "$type\t$isochore\t$cutoff\n";

    # Re-write the model file with the new cutoff inserted
    my $outfile="$OUTDIR/$type$isochore.model";
    open(IN,$model) || die $model;
    open(OUT,">$outfile") || die $outfile;
    for(my $i=0 ; $i<2 ; ++$i) { $_=<IN>; print OUT $_ }
    <IN>; # ignore the old cutoff
    print OUT "$cutoff\n";
    while(<IN>) { print OUT $_}
    close(OUT);
    close(IN);
    #my $scoresFile="$type$isochore.scores";
    #open(SCORES,">$scoresFile") || die $scoresFile;
    #foreach my $score (@$scores) { print SCORES "$score\n" }
    #close(SCORES);
  }
}
sub getScores {
  my ($command,$cutoff)=@_;
  my $scores=[];
  open(PIPE,"$command |") || die;
  while(<PIPE>) {
    chomp; my @fields=split; next unless @fields>=8;
    my ($substrate,$source,$type,$begin,$end,$score,$strand,$frame)=@fields;
    next unless $strand eq "+" && $begin==81;
    push @$scores,$score;
  }
  close(PIPE);
  return $scores;
}

