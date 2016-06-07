#!/usr/bin/perl
use strict;
use ProgramName;

my $ETHNIC="inactivation-analysis-het2.txt";
my $POP_FILE="populations.txt";

my %pop;
open(IN,$POP_FILE) || die $POP_FILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($indiv,$pop)=@fields;
  $pop{$indiv}=$pop;
}
close(IN);

my (%ethnicGenes,%ethnicTranscripts);
open(IN,$ETHNIC) || die $ETHNIC;
while(<IN>) {
  chomp; @fields=split;
  next unless @fields>=4 && $fields[3]=~/P=(\S+)/;
  my ($pop,$transcript,$gene)=@fields;
  $ethnicGenes{$pop}->{$gene}=1;
  $ethnicTransripts{$pop}->{$transcript}=1;
}
close(IN);




