#!/usr/bin/perl
use strict;
use GffTranscriptReader;
use FastaReader;

# Globals and constants
my $MAX_GROUP_SIZE=10;
my $SUBSTRATE="X";#"ENSG00000198947.10_1";
my $BASE="/home/bmajoros/1000G/assembly/DMD";
my $GFF="$BASE/ref-rev.gff";
my $FASTA="$BASE/ref-rev.fasta";
my $HEADER="$BASE/header.vcf";
my $OUT_VCF="$BASE/vcf/chrX.vcf.gz";
my $OUT_GENDER="$BASE/config/gender.txt";

# Load GFF & FASTA
my $reader=new GffTranscriptReader;
my $transcripts=$reader->loadGFF($GFF);
my $transcript=$transcripts->[0]; die unless $transcript;
my $chrom=FastaReader::firstSequence($FASTA);

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
  my $index=$i+1;
  if($L%3==0) { print "exon $index is divisible by 3 ($L)\n" }
}

# Identify groups of exons divisible by 3
for(my $i=1 ; $i+1<$numExons ; ++$i) {
  for(my $j=$i+1 ; $j+1<$numExons ; ++$j) {
    next unless $j-$i<$MAX_GROUP_SIZE;
    next unless $lengths[$i]%3>0 && $lengths[$j]%3>0;
    my $sum=0;
    for(my $k=$i ; $k<=$j ; ++$k) { $sum+=$lengths[$k] }
    if($sum%3==0) {
      #print "div by 3 group: ";
      for(my $k=$i ; $k<=$j ; ++$k) {
	my $residue=$lengths[$k]%3;
	my $exonNum=$k+1;
	print "$exonNum($residue) ";
      }
      print "\n";
      last;
    }
  }
}

# Simulate splice-disrupting variants
open(OUT,"|bgzip>$OUT_VCF") || die $OUT_VCF;
open(IN,$HEADER) || die $HEADER;
while(<IN>) {
  if(/^#CHROM/)
    { print OUT "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT" }
  else { print OUT }
}
close(IN);
my @indivs;
open(GENDER,">$OUT_GENDER") || DIE $OUT_GENDER;
for(my $i=0 ; $i<@spliceSites ; ++$i) {
  my $sites=$spliceSites[$i];
  my $exon=$i+2;
  my $donor=$sites->{donor}; my $acceptor=$sites->{acceptor};
  my $indiv1="exon${exon}acceptor"; push @indivs,$indiv1; print OUT "\t$indiv1";
  my $indiv2="exon${exon}donor"; push @indivs,$indiv2; print OUT "\t$indiv2";
  print GENDER "$indiv1\tmale\n$indiv2\tmale\n";
}
close(GENDER);
print OUT "\n";
my $numIndivs=@indivs;
my $indivIndex=0;
for(my $i=0 ; $i<@spliceSites ; ++$i) {
  my $sites=$spliceSites[$i];
  my $exon=$i+2;
  my $donor=$sites->{donor}; my $acceptor=$sites->{acceptor};
  my $refDonor=substr($chrom,$donor-1,3);
  my $refAcceptor=substr($chrom,$acceptor-1,3);
  #my $refDonor=substr($chrom,$donor-6,13);
  #my $refAcceptor=substr($chrom,$acceptor-6,13);
  simulate($acceptor,$refAcceptor,"exon${exon}acceptor",\*OUT,$indivIndex++,
	  $numIndivs);
  simulate($donor,$refDonor,"exon${exon}donor",\*OUT,$indivIndex++,$numIndivs);
}
close(OUT);

#======================================================================
sub simulate {
  my ($pos,$ref,$indiv,$fh,$indivIndex,$numIndivs)=@_;
  my $alt=substr($ref,0,1);
  $pos-=5;
  print $fh "$SUBSTRATE\t$pos\t$indiv\t$ref\t$alt\t100\tPASS\tVT=DEL\tGT\t";
  for(my $i=0 ; $i<$numIndivs ; ++$i) {
    my $genotype=($i==$indivIndex ? 1 : 0);
    print $fh "$genotype";
    if($i+1<$numIndivs) { print $fh "\t" }
  }
  print $fh "\n";
}

#  20      60343   rs527639301     G       A       100     PASS    AC=1;AF=0.000199681;AN=5008;NS=2504;DP=20377;EAS_AF=0;AMR_AF=0.0014;AFR_AF=0;EUR_AF=0;SAS_AF=0;AA=.|||;VT=SNP   GT




