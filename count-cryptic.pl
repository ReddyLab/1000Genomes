#!/usr/bin/perl
use strict;
use EssexParser;
use EssexFBI;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexFBI($elem);
  next unless$report->hasBrokenSpliceSite();
  next unless $elem->findDescendent("alternate-structures");
  my $array=$report->getAltTranscripts();
  next unless @$array>0;
  my $crypticCount=0;
  foreach my $transcript (@$array) {
    my $change=$transcript->{structureChange};
    if($change eq "cryptic-site") { ++$crypticCount }
  }
  print "$crypticCount\n";
  undef $elem; undef $report;
}

