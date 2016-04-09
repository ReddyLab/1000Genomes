#!/usr/bin/perl
use strict;
use EssexParser;
use EssexFBI;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my ($numFrameshift,$nmd);
my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexFBI($elem);
  next unless $report->frameshift();
  ++$numFrameshift;
  if($report->mappedNMD(50)) { ++$nmd }
}
my $percent=$nmd/$numFrameshift;
print "$nmd / $numFrameshift = $percent\n";

