#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;

my $name=ProgramName::get();
die "$name <infile.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexFBI($essexReportElem);
  next unless $report->getStatusString() eq "mapped";
  my $substrate=$report->getSubstrate();
  my $transcriptID=$report->getTranscriptID();
  my $cigar=$report->getCigar();
  my $transcript=$report->getMappedTranscript();


}







