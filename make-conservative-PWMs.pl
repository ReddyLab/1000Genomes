#!/usr/bin/perl
use strict;

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
    my $fasta="$RSVP/iso$isochore/$type$isochore.fasta";
    my $model="$MODELS/$type$isochore.model";
    my $cutoff=-30;
    my $scores=getScores("$SCORER -C $model $type $fasta");
    @$scores=sort {$a <=> $b} @$scores;
    my $N=@$scores;
    my $mid=$N/2;
    my $cutoff;
    if($mid%2==0) { $cutoff=$scores->[$mid] }
    else { $cutoff=($scores->[int($mid)]+$scores->[int($mid)+1])/2}
    print "$type\t$isochore\t$cutoff\n";
    my $outfile="$OUTDIR/$type$isochore.model";
    open(OUT,">$outfile") || die $outfile;
    close(OUT);
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

