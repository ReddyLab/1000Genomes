#!/usr/bin/perl
use strict;
use GffTranscriptReader;
use ProgramName;

my @keep=("protein_coding","pseudogene","lincRNA","processed_transcript","TR_V_pseudogene","polymorphic_pseudogene");
my %keep;
foreach my $type (@keep) {$keep{$type}=1}

my $name=ProgramName::get();
die "$name <infile.gff> <outfile.gff>\n" unless @ARGV==2;
my ($infile,$outfile)=@ARGV;

open(OUT,">$outfile") || die $outfile;
my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($infile);
my $n=@$transcripts;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $extra=$transcript->parseExtraFields();
  my $hash=$transcript->hashExtraFields($extra);
  my $type=$hash->{"gene_type"};
  next unless $keep{$type};
  my $status=$hash->{"gene_status"};
  next unless $status eq "KNOWN";
  my $gff=$transcript->toGff();
  print OUT $gff;
}
close(OUT);


