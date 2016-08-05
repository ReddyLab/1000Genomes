#!/usr/bin/perl
use strict;
use EssexParser;
use EssexICE;
use ProgramName;
$|=1;

my $MAX_COUNT;#=100;
my $THOUSAND="/home/bmajoros/1000G";
my $POP_FILE="$THOUSAND/assembly/populations.txt";

my $name=ProgramName::get();
die "$name <infile>\n" unless @ARGV==1;
my ($infile)=@ARGV;

$infile=~/([^\/]+)\/[^\/]+\.essex$/ || die "please give complete path to file";
my $id=$1;

my %pop;
open(IN,$POP_FILE) || die "can't open file: $POP_FILE\n";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($id,$pop)=@fields;
  $pop{$id}=$pop;
}
close(IN);
my $pop=$pop{$id};
my $ethnicFile="$THOUSAND/assembly/combined-ethnic/$pop/1.essex";

my $ethnicParser=new EssexParser($ethnicFile);
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  #my $ice=new EssexICE($root);
  my $transcriptID=$root->getAttribute("transcript-ID");
  my $status=$root->findDescendent("status");
  next unless $status;
  next unless $status->hasDescendentOrDatum("mapped");
  next unless $status->hasDescendentOrDatum("protein-differs");
  my $mappedTranscript=$root->findDescendent("mapped-transcript");
  next unless $mappedTranscript;
  my $mappedProtein=$mappedTranscript->getAttribute("translation");
  my $refTranscript=$root->findDescendent("reference-transcript");
  next unless $refTranscript;
  my $refProtein=$refTranscript->getAttribute("translation");
  my $refLen=length($refProtein); my $mappedLen=length($mappedProtein);
  next unless $refLen==$mappedLen;

  while(1) {
    my $root=$ethnicParser->nextElem();
    die "can't find $transcriptID in $ethnicFile\n" unless $root;
    my $ethnicTransID=$root->getAttribute("transcript-ID");
    next unless $ethnicTransID eq $transcriptID;
    my $mappedTranscript=$root->findDescendent("mapped-transcript");
    last unless $mappedTranscript;
    my $ethnicProtein=$mappedTranscript->getAttribute("translation");
    #print "$refProtein\n$mappedProtein\n$ethnicProtein\n";
    #print "===========\n";
    if(length($ethnicProtein)==$refLen)
      { analyze(\$refProtein,\$ethnicProtein,\$mappedProtein,$transcriptID) }
    last;
  }
}


sub analyze
{
  my ($refProtein,$ethnicProtein,$mappedProtein,$transcriptID)=@_;
  my $L=length($$refProtein);
  for(my $pos=0 ; $pos<$L ; ++$pos) {
    my $ref=substr($$refProtein,$pos,1);
    my $ethnic=substr($$ethnicProtein,$pos,1);
    my $mapped=substr($$mappedProtein,$pos,1);
    next unless $mapped ne $ref || $mapped ne $ethnic || $ethnic ne $ref;
    print "$id\t$transcriptID\t$ref\t$ethnic\t$mapped\n";
  }
}






