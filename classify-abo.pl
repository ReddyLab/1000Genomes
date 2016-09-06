#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $INFILE="$THOUSAND/abo.txt";
my $A_ALLELE="MAEVLRTLAGKPKCHALRPMILFLIMLVLVLFGYGVLSPRSLMPGSLERGFCMAVREPDHLQRVSLPRMVYPQPKVLTPCRKDVLVVTPWLAPIVWEGTFNIDILNEQFRLQNTTIGLTVFAIKKYVAFLKLFLETAEKHFMVGHRVHYYVFTDQPAAVPRVTLGTGRQLSVLEVRAYKRWQDVSMRRMEMISDFCERRFLSEVDYLVCVDVDMEFRDHVGVEILTPLFGTLHPGFYGSSREAFTYERRPQSQAYIPKDEGDFYYLGGFFGGSVQEVQRLTRACHQAMMVDQANGIEAVWHDESHLNKYLLRHKPTKVLSPEYLWDQQLLGWPAVLRKLRFTAVPKNHQAVRNP*";
my $B_ALLELE="MAEVLRTLAGKPKCHALRPMILFLIMLVLVLFGYGVLSPRSLMPGSLERGFCMAVREPDHLQRVSLPRMVYPQPKVLTPCRKDVLVVTPWLAPIVWEGTFNIDILNEQFRLQNTTIGLTVFAIKKYVAFLKLFLETAEKHFMVGHRVHYYVFTDQPAAVPRVTLGTGRQLSVLEVGAYKRWQDVSMRRMEMISDFCERRFLSEVDYLVCVDVDMEFRDHVGVEILTPLFGTLHPSFYGSSREAFTYERRPQSQAYIPKDEGDFYYMGAFFGGSVQEVQRLTRACHQAMMVDQANGIEAVWHDESHLNKYLLRHKPTKVLSPEYLWDQQLLGWPAVLRKLRFTAVPKNHQAVRNP*";
my $O_ALLELE="MAEVLRTLAGKPKCHALRPMILFLIMLVLVLFGYGVLSPRSLMPGSLERGFCMAVREPDHLQRVSLPRMVYPQPKVLTPCRKDVLVVPLGWLPLSGRAHSTSTSSTSSSGSRTPPLG*";
my %ALLELES;
$ALLELES{$A_ALLELE}="A";
$ALLELES{$B_ALLELE}="B";
$ALLELES{$O_ALLELE}="O";
my $nextAllele=1;

my %indiv;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($ind,$hap,$protein,$rna,$strand,$numExons,$exons)=@fields;
  my @exons=split/,/,$exons;
  my $exons=[];
  foreach my $exon (@exons) {
    $exon=~/(\d+)-(\d+)/ || die $exon;
    push @$exons,[$1,$2];
  }
  $indiv{$ind}->{$hap}=
    {
     protein=>$protein,
     rna=>$rna,
     numExons=>$numExons
    };
}
close(IN);

my @indiv=keys %indiv;
foreach my $indiv (@indiv) {
  my $numAlleles=keys %{$indiv{$indiv}};
  next unless $numAlleles==2;
  my $protein1=$indiv{$indiv}->{1}->{protein};
  my $protein2=$indiv{$indiv}->{2}->{protein};
  my $allele1=classify($protein1);
  my $allele2=classify($protein2);
  print "$indiv\t$allele1\t$allele2\n";
}

sub classify {
  my ($protein)=@_;
  my $allele=$ALLELES{$protein};
  if($allele) { return $allele }
  $ALLELES{$protein}="U$nextAllele";
  ++$nextAllele;
}



