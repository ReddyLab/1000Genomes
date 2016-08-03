#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
$|=1;

my $BROKEN="/home/bmajoros/1000G/assembly/broken.txt";
my $GFF="/home/bmajoros/1000G/assembly/local-genes.gff";

my $reader=new GffTranscriptReader;
my $transcripts=$reader->loadGFF($GFF);


open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$allele,$gene,$transcript,$chr)=@fields;
  next if $chr eq "chrX" || $chr eq "chrY";
  if($gene=~/(\S+)\./) { $gene=$1 }
  $alleles{$gene}->{$indiv}->{$allele}=1;
}
close(IN);


