#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile> <outfile\n" unless @ARGV==2;
my ($infile,$outfile)=@ARGV;

my (%donors,%acceptors,$N);
open(IN,$infile) || die $infile;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>=3;
  my ($type,$seq,$gene)=@fields;
  my $hash=$type eq "donor" ? \%donors : \%acceptors;
  ++$hash->{$seq};
  ++$n;
}
close(IN);

summarize(\%donors);
summarize(\%acceptors);

sub summarize
{
  my ($hash)=@_;
  my @keys=keys %$hash;
  foreach my $key (@keys) {
  }
}



