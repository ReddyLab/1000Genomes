#!/usr/bin/perl
use strict;
use GffTranscriptReader;

# Globals and constants
my $MAX_GROUP_SIZE=10;
my $BASE="/home/bmajoros/1000G/assembly/DMD";
my $GFF="$BASE/ref-rev.gff";
my $HEADER="$BASE/header.vcf";

# Load GFF
my $reader=new GffTranscriptReader;
my $transcripts=$reader->loadGFF($GFF);
my $transcript=$transcripts->[0]; die unless $transcript;

# Get exon lengths and splice site coordinates
my (@lengths,@spliceSites);
my $numExons=$transcript->numExons();
for(my $i=0 ; $i<$numExons ; ++$i) {
  my $exon=$transcript->getIthExon($i);
  my $exonLen=$exon->getLength();
  push @lengths,$exonLen;
  if($i>0 && $i<$numExons-1) {
    my $acceptor=$exon->getBegin()-2; my $donor=$exon->getEnd();
    push @spliceSites,{acceptor=>$acceptor,donor=>$donor};
  }
}

# Identify exons divisible by 3
for(my $i=1 ; $i+1<$numExons ; ++$i) {
  my $L=$lengths[$i];
  if($L%3==0) { print "exon $i is divisible by 3\n" }
}

# Identify groups of exons divisible by 3
for(my $i=1 ; $i+1<$numExons ; ++$i) {
  for(my $j=$i+1 ; $j+1<$numExons ; ++$j) {
    next unless $j-$i<$MAX_GROUP_SIZE;
    next unless $lengths[$i]%3>0 && $lengths[$j]%3>0;
    my $sum=0;
    for(my $k=$i ; $k<=$j ; ++$k) { $sum+=$lengths[$k] }
    if($sum%3==0) {
      print "div by 3 group: ";
      for(my $k=$i ; $k<=$j ; ++$k) {
	my $residue=$lengths[$k]%3;
	print "$k($residue) ";
      }
      print "\n";
      last;
    }
  }
}


#  20      60343   rs527639301     G       A       100     PASS    AC=1;AF=0.000199681;AN=5008;NS=2504;DP=20377;EAS_AF=0;AMR_AF=0.0014;AFR_AF=0;EUR_AF=0;SAS_AF=0;AA=.|||;VT=SNP   GT




