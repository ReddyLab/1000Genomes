#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;

my $name=ProgramName::get();
die "$name <in.gff> <junctions.bed>\n" unless @ARGV==2;
my ($gffFile,$junctionsFile)=@ARGV;

# Load the TopHat junctions file
my $introns=parseTophat($junctionsFile);

# Process the GFF
my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($gffFile);


print STDERR "[done]\n";



#########################################################################
#########################################################################
sub parseTophat {
  my ($filename)=@_;
  my $introns=[];
  open(IN,$filename) || die "Can't open $filename";
  <IN>; # header
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=10;
    my ($gene,$begin,$end,$junc,$reads,$strand,$b,$e,$color,$two,$overhangs)=
      @fields;
    $overhangs=~/(\d+),(\d+)/ || die $overhangs;
    my $donor=$begin+$1; my $acceptor=$end-$2;
    my $record=
      {
       gene=>$gene,
       donor=>$donor,
       acceptor=>$acceptor
      };
  }
  close(IN);
}





