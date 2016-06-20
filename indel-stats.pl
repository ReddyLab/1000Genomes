#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my (%indivsWithFrameshifts,%allIndivs,%genesWithFrameshifts,
    %transcriptsWithFrameshifts);
my @dirs=`ls $COMBINED`;
foreach my $dir (@dirs) {
  chomp $dir;
  next unless $dir=~/HG\d+/ || $dir=~/NA\d+/;
  $allIndivs{$dir}=1;
  process("$COMBINED/$dir/1-indels.txt",$dir);
  process("$COMBINED/$dir/2-indels.txt",$dir);
}
my @indivs=keys %allIndivs;
my $numIndivs=@indivs;
my $numIndivsWithFrameshifts;
foreach my $indiv (@indivs) {
  if($indivsWithFrameshifts{$indiv}) { ++$numIndivsWithFrameshifts }
}
my $percentIndivsWithFrameshifts=$numIndivsWithFrameshifts/$numIndivs;
print "$percentIndivsWithFrameshifts = $numIndivsWithFrameshifts\/$numIndivs = proportion of indivs with frameshifts\n";
my @genesWithFrameshifts=keys %genesWithFrameshifts;
my $numGenesWithFrameshifts=@genesWithFrameshifts;
my @transcriptsWithFrameshifts=keys %transcriptsWithFrameshifts;
my $numTranscriptsWithFrameshifts=@transcriptsWithFrameshifts;
print "$numGenesWithFrameshifts genes had a frameshift in at least one individual\n";
print "$numTranscriptsWithFrameshifts transcripts had a frameshift in at least one individual\n";



sub process
{
  my ($filename,$indiv)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=5;
    if(/NOT CORRECTED/) {
      $indivsWithFrameshifts{$indiv}=1;
      my $geneID=$fields[4];
      my $transcriptID=$fields[5];
      $genesWithFrameshifts{$geneID}=1;
      $transcriptsWithFrameshifts{$transcriptID}=1;

    }
    else {
      $indivsWithFrameshifts{$indiv}=1;
      my $geneID=$fields[2];
      my $transcriptID=$fields[3];
      $genesWithFrameshifts{$geneID}=1;
      $transcriptsWithFrameshifts{$transcriptID}=1;

    }
  }
  close(IN);
}





