#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile> <outfile\n" unless @ARGV==2;
my ($infile,$outfile)=@ARGV;

my (%donors,%acceptors);
open(IN,$infile) || die $infile;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>=3;
  my ($type,$seq,$gene)=@fields;
  my $hash=$type eq "donor" ? \%donors : \%acceptors;
  ++$hash->{$seq};
}
close(IN);

open(OUT,">$outfile") || die $outfile;
my $totalGT=summarize(\%donors,"GT","GC","AT");
my $totalAG=summarize(\%acceptors,"AG","AC");
print OUT "DONORS $totalGT\n";
print OUT "ACCEPTORS $totalAG\n";
dumpHash(\%donors,"donor");
dumpHash(\%acceptors,"acceptor");
close(OUT);

sub dumpHash
{
  my ($hash,$label)=@_;
  my @keys=keys %$hash;
  foreach my $key (@keys) {
    my $value=$hash->{$key};
    print OUT "$label\t$key\t$value\n";
  }
}

sub summarize
{
  my $hash=shift @_;
  my @keys=keys %$hash;
  my $n=0;
  foreach my $key (@keys) { $n+=$hash->{$key} }
  foreach my $key (@keys) { $hash->{$key}/=$n }
  my $total=0;
  foreach my $seq (@_) { $total+=$hash->{$seq} }
  return $total;
}



