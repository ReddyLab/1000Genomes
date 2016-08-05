#!/usr/bin/perl
use strict;
use EssexParser;
use EssexICE;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my ($numFrameshift,$nmd);
my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexICE($elem);
  next unless $report->frameshift();
  ++$numFrameshift;
  if($report->mappedNMD(50)) { ++$nmd }
  undef $elem; undef $report;
}
my $percent=$nmd/$numFrameshift;
print "$nmd / $numFrameshift = $percent\n";

