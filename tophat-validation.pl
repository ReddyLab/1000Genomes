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
my $transcriptHash=hashTranscriptIDs($transripts);


print STDERR "[done]\n";



#########################################################################
#########################################################################

sub hashTranscriptIDs {
  my ($transcripts)=@_;
  my $hash={};
  my $n=@$transcripts;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $transcript=$transcripts->[$i];
    my $id=$transcript->getTranscriptId();
    $hash->{$id}=$transcript;
  }
  return $hash;
}


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





