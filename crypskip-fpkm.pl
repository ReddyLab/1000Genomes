#!/usr/bin/perl
use strict;

my $READS=0; # 1 = use spliced read counts (TopHat), 0 = use FPKM (StringTie)

my $MIN_FPKM=1;
my $MIN_SAMPLE_SIZE=30;
my $MAX_COPIES=100;
my $BASE="/home/bmajoros/1000G/assembly";
my $CRYPSKIP="$BASE/crypskip.txt";
my $RNA=$READS ? "$BASE/crypskip-counts.txt" : "$BASE/rna.txt";

my (%rna,%rnaByTranscript,%sampleSize,%seen);
open(IN,$RNA) || die $RNA;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM,$nmd)=@fields;
  next if $indiv eq "indiv"; # header
  #next unless $nmd eq "OK";
  my $key="$indiv $allele";
  next if $transcript eq ".";
  if($transcript=~/(ALT\d+_\S+)_\d+/) { $transcript=$1 }
  my $baseID=$transcript;
  if($transcript=~/ALT\d+_(\S+)/) { $baseID=$1 }
  $seen{$baseID}++;
  $rna{$key}->{$transcript}=$FPKM;
  if($READS) {
    $rnaByTranscript{$baseID}+=$FPKM;
    ++$sampleSize{$baseID};
  }
}
close(IN);

if(!$READS) {
  open(IN,"$BASE/rna.txt") || die;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=7;
    my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM,$nmd)=@fields;
    next if $indiv eq "indiv"; # header
    my $key="$indiv $allele";
    if($transcript=~/ALT\d+_(\S+)/) { $transcript=$1 }
    $rnaByTranscript{$transcript}+=$FPKM;
    ++$sampleSize{$transcript};
  }
  close(IN);
}

my (%crypticCounts,%exonSkipping,%baseIDs);
open(IN,$CRYPSKIP) || die $CRYPSKIP;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=6;
  my ($indiv,$hap,$gene,$transcript,$event,$dist)=@fields;
  $transcript=~/(\S+)_\d+$/ || die $transcript;
  $transcript=$1;
  my $baseID=$transcript;
  if($transcript=~/ALT\d+_(\S+)/) { $baseID=$1 }
  $baseIDs{$baseID}=1;
  my $key="$indiv $hap";

  #print "$key $transcript\n";
  if($event eq "exon-skipping") {next unless $rna{$key}->{$transcript}>0} ###
  #next unless $rna{$key}->{$transcript}>0; ###

  if($event eq "exon-skipping") { $exonSkipping{$key}->{$baseID}=$transcript }
  else { ++$crypticCounts{$key}->{$baseID} }
}
close(IN);

my %meanFPKM;
my @baseIDs=keys %rnaByTranscript;
my $numBaseIDs=@baseIDs;
for(my $i=0 ; $i<$numBaseIDs ; ++$i) {
  my $baseID=$baseIDs[$i];
  my $sum=$rnaByTranscript{$baseID};
  my $N=$sampleSize{$baseID};
  next unless $sum>$MIN_FPKM && $N>$MIN_SAMPLE_SIZE;
  $meanFPKM{$baseID}=$sum/$N;
}

my @keys=keys %exonSkipping;
my $numKeys=@keys;
for(my $i=0 ; $i<$numKeys ; ++$i) {
  my $key=$keys[$i];
  my $hash=$exonSkipping{$key};
  die unless $hash;
  my @baseIDs=keys %$hash;
  foreach my $baseID (@baseIDs) {
    my $numCryptic=defined($crypticCounts{$key}) ?
      0+$crypticCounts{$key}->{$baseID} : 0;
    my $skippingID=$hash->{$baseID};
    my $fpkm=0+$rna{$key}->{$skippingID};
    my $mean=$meanFPKM{$baseID};
    next unless $mean>$MIN_FPKM;
    #next if $baseID=~/ENST00000421308.2/; # outlier: common allele
    next if $seen{$baseID}>$MAX_COPIES;
    print "dividing $fpkm by $mean\n";
    $fpkm/=$mean;
    print "$baseID\t$numCryptic\t$fpkm\n";
  }
}



