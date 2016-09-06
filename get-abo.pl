#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use FastaReader;

my $ABO="ENSG00000175164.9";

my $name=ProgramName::get();
die "$name <indiv> <hap> <in.fasta> <in.essex>\n" unless @ARGV==4;
my ($indiv,$hap,$fastaFile,$essexFile)=@ARGV;

my $aboChunk;
my $reader=new FastaReader($fastaFile);
while(1) {
  my ($def,$seqRef)=$reader->nextSequenceRef();
  last unless $def;
  $def=~/^>(\S+)/ || $die $def;
  next unless $id eq $ABO;
  $aboChunk=$$seqRef;
  $reader->close();
  last;
}
my $L=length($aboChunk);
die unless $L>0;

my $aboElem;
my $parser=new EssexParser($essexFile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $geneID=$root->getAttribute("gene-ID");
  next unless $geneID eq $ABO;
  $aboElem=$root;
  last;
}

