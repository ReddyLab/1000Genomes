#!/usr/bin/perl
use strict;

my $MIN_FPKM=1;
my $MIN_SAMPLE_SIZE=30;
my $BASE="/home/bmajoros/1000G/assembly";
my $CRYPSKIP="$BASE/crypskip.txt";
my $RNA="$BASE/rna.txt";

my (%rna,%rnaByTranscript,%sampleSize);
open(IN,$RNA) || die $RNA;
<IN>; # header
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  my $key="$indiv $allele";
  #if($transcript=~/ALT\d+_(\S+)/) { $transcript=$1 }
  #print "key=\"$key\" transcript=\"$transcript\" FPKM=\"$FPKM\"\n";
  $rna{$key}->{$transcript}=$FPKM;
  $rnaByTranscript{$transcript}+=$FPKM;
  ++$sampleSize{$transcript};
}
close(IN);

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
    #$fpkm/=$mean;
    print "$baseID\t$numCryptic\t$fpkm\n";
  }
}

#indiv   allele  gene    transcript      cov     FPKM    TPM
#HG00096 1       ENSG00000042088.9       ALT1_ENST00000393452.3  2.948879        0.867289        1.876076



