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

my $totalGT=summarize(\%donors,"GT","GC","AT");
my $totalAG=summarize(\%acceptors,"AG","AC");
print "DONORS $totalGT\n";
print "ACCEPTORS $totalAG\n";
dumpHash(\%donors,"donor");
dumpHash(\%acceptors,"acceptor");

sub dumpHash
{
  my ($hash,$label)=@_;
  my @keys=keys %$hash;
  foreach my $key (@keys) {
    my $value=$hash->{$key};
    print "$label\t$key\t$value\n";
  }
}

sub summarize
{
  my $hash=shift @_;
  my @keys=keys %$hash;
  foreach my $key (@keys) {
    $hash->{$key}=$value/$n;
  }
  my $total=0;
  foreach my $seq (@_) {
    $total+=$hash->{$seq};
  }
  return $total;
}



