#!/usr/bin/perl
use strict;
use EssexParser;
use ProgramName;

my $name=ProgramName::get();
die "$name in.essex > out.essex\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $status=$root->findChild("status");
  if(!$status) { die "no status node" }
  my $statusString=$status->getIthElem(0);
  if($statusString eq "splicing-changes") {
    my $altNode=$status->findChild("alternate-structures");
    if($altNode) {
      
    }
  }
  $root->print(\*STDOUT);
}

print STDERR "[done]\n";






