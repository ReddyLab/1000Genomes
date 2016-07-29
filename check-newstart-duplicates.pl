#!/usr/bin/perl
use strict;
use GffTranscriptReader;
$|=1;

my $MEMORY=5000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";
  process($subdir,1,"$dir/1.gff");
  process($subdir,2,"$dir/2.gff");
}

sub process {
  my ($indiv,$hap,$infile)=@_;
  my $reader=new GffTranscriptReader;
  my $hash=$reader->loadTranscriptIdHash($infile);
  my @keys=keys %$hash;
  my $n=@keys; my $found=0; my $total=0;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $id=$keys[$i];
    next unless $id=~/NEWSTART_(\S+)/;
    my $parentId=$1;
    my $transcript=$hash->{$id}; die unless $transcript;
    my $parent=$hash->{$parentId};
    #if($parent) { print "$id found\n" }
    #else { print "$id NOT FOUND ******\n" }
    if($parent) { ++$found }
    ++$total;
  }
  print "$indiv\t$hap\t$found of $total found\n";
}






