#!/usr/bin/perl
use strict;
use SummaryStats;

# Some globals
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

# Process input files
my (%indivsWithFrameshifts,%allIndivs,%genesWithFrameshifts,
    %transcriptsWithFrameshifts,%indivsWithCompensatory,%genesWithCompensatory,
    %transcriptsWithCompensatory,%frameshiftLengthsByGene,%lengths,
    %correctingVariants);
my @dirs=`ls $COMBINED`;
foreach my $dir (@dirs) {
  chomp $dir;
  next unless $dir=~/HG\d+/ || $dir=~/NA\d+/;
  $allIndivs{$dir}=1;
  process("$COMBINED/$dir/1-indels.txt",$dir);
  process("$COMBINED/$dir/2-indels.txt",$dir);
}

# Individuals with at least one frameshift
my @indivs=keys %allIndivs;
my $numIndivs=@indivs;
my $numIndivsWithFrameshifts;
foreach my $indiv (@indivs) {
  if($indivsWithFrameshifts{$indiv}) { ++$numIndivsWithFrameshifts }
}
print "$numIndivsWithFrameshifts indivs had at least one frameshift\n";

# Genes/transcript with at least one frameshift
my @genesWithFrameshifts=keys %genesWithFrameshifts;
my $numGenesWithFrameshifts=@genesWithFrameshifts;
my @transcriptsWithFrameshifts=keys %transcriptsWithFrameshifts;
my $numTranscriptsWithFrameshifts=@transcriptsWithFrameshifts;
print "$numGenesWithFrameshifts genes had a frameshift in at least one individual\n";
print "$numTranscriptsWithFrameshifts transcripts had a frameshift in at least one individual\n";

# Keys of hashes
my @genesWithCompensatory=keys %genesWithCompensatory;
my @transcriptsWithCompensatory=keys %transcriptsWithCompensatory;
my @indivsWithCompensatory=keys %indivsWithCompensatory;

# Compensatory indels per individual
my @counts;
foreach my $indiv (@indivsWithCompensatory) {
  my $count=keys %{$indivsWithCompensatory{$indiv}};
  push @counts,$count;
}
my ($mean,$stddev,$min,$max)=SummaryStats::roundedSummaryStats(\@counts);
print "each indiv had compensatory indels in $mean +- $stddev genes\n";

# Frameshifts per individual
my @counts; my @indivsWithFrameshifts=keys %indivsWithFrameshifts;
foreach my $indiv (@indivsWithFrameshifts) {
  my $count=keys %{$indivsWithFrameshifts{$indiv}};
  push @counts,$count;
}
my ($mean,$stddev,$min,$max)=SummaryStats::roundedSummaryStats(\@counts);
print "each indiv had frameshifts in $mean +- $stddev genes\n";

# Genes/transcripts/individuals with compensatory frameshifts
my $numGenesWithCompensatory=@genesWithCompensatory;
my $numTranscriptsWithCompensatory=@transcriptsWithCompensatory;
my $numIndivsWithCompensatory=@indivsWithCompensatory;
print "$numIndivsWithCompensatory individuals had at least one compensatory indel\n";
print "$numGenesWithCompensatory genes had a least one transcript with compensatory indels\n";
print "$numTranscriptsWithCompensatory transcripts had at least one compensatory indel\n";

# Histogram of lengths of altered protein intervals
my @sorted=sort {(keys(%{$genesWithCompensatory{$b}})+0) <=>
		   (keys(%{$genesWithCompensatory{$a}})+0)}
  @genesWithCompensatory;
for(my $i=0 ; $i<@sorted ; ++$i) {
  my $gene=$sorted[$i];
  my $count=keys %{$genesWithCompensatory{$gene}};
  print "$gene had compensatories in $count individuals\n";}
my @genes=keys %lengths;
open(OUT,">compensatory-lengths.txt") || die;
foreach my $gene (@genes)
  { my $length=$lengths{$gene}; print OUT "$length\n" }
close(OUT);

# Number of variants involved in correcting a frameshift
open(OUT,">correcting-variants.txt") || die;
foreach my $x (values %correctingVariants) { print OUT "$x\n" }
close(OUT);




#==========================================================================
sub process
{
  my ($filename,$indiv)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=5;
    if(/NOT CORRECTED/) {
      my $geneID=$fields[4];
      $indivsWithFrameshifts{$indiv}->{$geneID}=1;
      my $geneID=$fields[4];
      $genesWithFrameshifts{$geneID}=1;
      my $transcriptID=$fields[5];
      $transcriptsWithFrameshifts{$transcriptID}=1;

    }
    elsif(/exon/) { # compensatory frameshifts
      my $length=$fields[4];
      next if $length>30;
      #die $_ unless $length>0;
      my $geneID=$fields[2];
      $indivsWithFrameshifts{$indiv}->{$geneID}=1;
      $indivsWithCompensatory{$indiv}->{$geneID}=1;
      $genesWithFrameshifts{$geneID}=1;
      $genesWithCompensatory{$geneID}->{$indiv}=1;
      my $transcriptID=$fields[3];
      $transcriptsWithFrameshifts{$transcriptID}=1;
      $transcriptsWithCompensatory{$transcriptID}->{$indiv}=1;
      $fields[5]=~/^(\d+)/ || die $fields[5];
      my $variantID="$geneID\@$1";
      if($lengths{$variantID}==0 ||
	 $lengths{$variantID}>0 && $length>$lengths{$variantID})
	{ $lengths{$variantID}=$length }
      my @variants=split/,/,$fields[5];
      my $numVariants=@variants;
      my $numCorrectingVariants=$numVariants-1;
      $correctingVariants{$variantID}=$numCorrectingVariants;
    }
  }
  close(IN);
}





