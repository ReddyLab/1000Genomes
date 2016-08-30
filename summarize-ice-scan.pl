#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <ice-scan.txt>\n" unless @ARGV==1;
my ($INFILE)=@ARGV;

my $THOUSAND="/home/bmajoros/1000G/assembly";
#my $INFILE="$THOUSAND/scan/ice-scan.txt";

my (%seen,$sites,$sitesOK,%genes,%genesOK);
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=3;
  my ($gene,$pos,$ok)=@fields;
  my $key="$gene $pos";
  next if $seen{$key};
  $seen{$key}=1;
  ++$sites;
  $sitesOK+=$ok;
  ++$genes{$gene};
  if($ok) { ++$genesOK{$gene} }
}
close(IN);

my $numGenes=keys %genes;
my $numGenesOK=keys %genesOK;
my $r=int($numGenesOK/$numGenes*1000+5/9)/10;
print "genes: $numGenesOK / $numGenes = $r %\n";

my $r=int($sitesOK/$sites*1000+5/9)/10;
print "sites: $sitesOK / $sites = $r %\n";


