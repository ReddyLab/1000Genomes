#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.gff> <in.tab.txt>\n" unless @ARGV==2;
my ($GFF,$TAB)=@ARGV;

# Process the GFF file
my %FPKM;
open(IN,$GFF) || die "can't open $GFF";
while(<IN>) {
  if(/transcript_id\s+"\S\S\S\d+_[^\"]+"/) { $FPKM{$1}=0 }
}
close(IN);

# Process the tab.txt file
open(IN,$TAB) || die "can't open $TAB";
while(<IN>) {
  
}
close(IN);



