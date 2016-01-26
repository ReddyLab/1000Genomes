#!/usr/bin/perl
use strict;
use GffTranscriptReader;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.gff> <out.gff>\n" unless @ARGV==2;
my ($infile,$outfile)=@ARGV;

my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($infile);
open(OUT,">$outfile") || die $outfile;
my $numTranscripts=@$transcripts;
for(my $i=0 ; $i<$numTranscripts ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $keyValuePairs=$transcript->parseExtraFields();
  my $hash=$transcript->hashExtraFields($keyValuePairs);
  my $substrate=$transcript->getSubstrate();
  $transcript->setGeneId($substrate);
  if(defined($hash->{"reference_id"})) {
    my $transcriptID=$hash->{"reference_id"};
    $transcript->setTranscriptId($transcriptID);
  }
  my @filteredPairs;
  foreach my $pair (@$keyValuePairs) {
    my ($key,$value)=@$pair;
    next if $key eq "gene_id" || $key eq "transcript_id" ||
      $key eq "reference_id" || $key eq "ref_gene_id";
    #print "AAA $key $value\n";
    push @filteredPairs,$pair;
  }
  $transcript->setExtraFieldsFromKeyValuePairs(\@filteredPairs);
  my $gff=$transcript->toGff();
  print OUT $gff;
}
close(OUT);






