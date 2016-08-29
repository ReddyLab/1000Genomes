#!/usr/bin/perl
use strict;

my $HOME="/home/bmajoros";
my $RSVP="$HOME/RSVP/isochores";
my $MODELS="$HOME/1000G/ICE/model";
my @ISOCHORES=("0-43","43-51","51-57","57-100");

process("donors");
process("acceptors");

#=====================================================================


