#!/usr/bin/perl
use strict;

my $HOME="/home/bmajoros";
my $RSVP="$HOME/RSVP/isochores";
my $MODELS="$HOME/1000G/ICE/model";
my $ICE="$HOME/ICE";
my $SCORER="$ICE/apply-signal-sensor";
my @ISOCHORES=("0-43","43-51","51-57","57-100");

process("donors");
process("acceptors");

#=====================================================================
sub process {
  my ($type)=@_;
  foreach my $isochore (@ISOCHORES) {
    my $fasta="$RSVP/iso$isochore/$type.fasta";
    my $model="$MODELS/donors$isochore.model";
    open(PIPE,"$SCORER -C $model $type $fasta") || die;
    while(<PIPE>) {
      print "$_";
    }
    close(PIPE);
  }
}


