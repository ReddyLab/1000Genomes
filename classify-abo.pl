#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $INFILE="$THOUSAND/abo.txt";
my $A_ALLELE="MAEVLRTLAGKPKCHALRPMILFLIMLVLVLFGYGVLSPRSLMPGSLERGFCMAVREPDHLQRVSLPRMVYPQPKVLTPCRKDVLVVTPWLAPIVWEGTFNIDILNEQFRLQNTTIGLTVFAIKKYVAFLKLFLETAEKHFMVGHRVHYYVFTDQPAAVPRVTLGTGRQLSVLEVRAYKRWQDVSMRRMEMISDFCERRFLSEVDYLVCVDVDMEFRDHVGVEILTPLFGTLHPGFYGSSREAFTYERRPQSQAYIPKDEGDFYYLGGFFGGSVQEVQRLTRACHQAMMVDQANGIEAVWHDESHLNKYLLRHKPTKVLSPEYLWDQQLLGWPAVLRKLRFTAVPKNHQAVRNP*";
my $B_ALLELE="MAEVLRTLAGKPKCHALRPMILFLIMLVLVLFGYGVLSPRSLMPGSLERGFCMAVREPDHLQRVSLPRMVYPQPKVLTPCRKDVLVVTPWLAPIVWEGTFNIDILNEQFRLQNTTIGLTVFAIKKYVAFLKLFLETAEKHFMVGHRVHYYVFTDQPAAVPRVTLGTGRQLSVLEVGAYKRWQDVSMRRMEMISDFCERRFLSEVDYLVCVDVDMEFRDHVGVEILTPLFGTLHPSFYGSSREAFTYERRPQSQAYIPKDEGDFYYMGAFFGGSVQEVQRLTRACHQAMMVDQANGIEAVWHDESHLNKYLLRHKPTKVLSPEYLWDQQLLGWPAVLRKLRFTAVPKNHQAVRNP*";
my $O_ALLELE="MAEVLRTLAGKPKCHALRPMILFLIMLVLVLFGYGVLSPRSLMPGSLERGFCMAVREPDHLQRVSLPRMVYPQPKVLTPCRKDVLVVPLGWLPLSGRAHSTSTSSTSSSGSRTPPLG*";
my $A_LEN=length($A_ALLELE);
my $B_LEN=length($B_ALLELE);
my $O_LEN=length($O_ALLELE);
my $nextA=1; my $nextB=1; my $nextO=1;
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
--$nextA; --$nextB; --$nextO; --$nextAllele;
print "$nextA alternate A alleles\n";
print "$nextB alternate B alleles\n";
print "$nextO alternate O alleles\n";
print "$nextAllele unknown alleles\n";

#==============================================================
sub classify {
  my ($protein)=@_;
  my $allele=$ALLELES{$protein};
  if($allele) { return $allele }
  my $L=length($protein);
  if($L==$A_LEN) {
    my $diffsA=compare($protein,$A_ALLELE);
    my $diffsB=compare($protein,$B_ALLELE);
    if($diffsA<$diffsB)
      { $allele=$ALLELES{$protein}="A_d$diffsA\_$nextA"; ++$nextA }
    else { $allele=$ALLELES{$protein}="B_d$diffsB\_$nextB"; ++$nextB }
  }
  elsif($L==$O_LEN) {
    my $diffs=compare($protein,$O_ALLELE);
    $allele=$ALLELES{$protein}="O_d$diffs\_$nextO";
    ++$nextO;
  }
  else {
    $allele=$ALLELES{$protein}="U_$L\_$nextAllele";
    ++$nextAllele;
  }
  return $allele;
}

sub compare {
  my ($seq1,$seq2)=@_;
  my $L=length($seq1); die unless length($seq2)==$L;
  my $diffs=0;
  for(my $i=0 ; $i<$L ; ++$i)
    { if(substr($seq1,$i,1) ne substr($seq2,$i,1)) {++$diffs} }
  return $diffs;
}


