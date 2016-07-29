#!/usr/bin/perl
use strict;
use GffTranscriptReader;

my $MEMORY=5000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";
  process("$dir/1.gff");
  process("$dir/2.gff");
}

sub process {
  my ($infile)=@_;
  my $reader=new GffTranscriptReader;
  my $hash=$reader->loadTranscriptIdHash($infile);
  my @keys=keys %$hash;
  my $n=@keys;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $id=$keys[$i];
    next unless $id=~/NEWSTART_(\S+)/;
    my $parentId=$1;
    my $transcript=$hash->{$id}; die unless $transcript;
    my $parent=$hash->{$parentId};
    if($parent) { print "$id found\n" }
    else { print "$id NOT FOUND ******\n" }
  }
}






