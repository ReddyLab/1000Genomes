#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;

my $name=ProgramName::get();
die "$name <infile.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexFBI($elem);
  next unless $report->getStatusString() eq "mapped";
  my $substrate=$report->getSubstrate();
  my $transcriptID=$report->getTranscriptID();
  my $cigar=$report->getCigar();
  my $transcript=$report->getMappedTranscript();

  my $indels=parseCigar($cigar);
  my $numExons=$transcript->numExons();
  for(my $i=0 ; $i<$numExons ; ++$i) {
    my $exon=$transcript->getIthExon($i);
    my $netIndel=0; my $hasFrameshiftIndel=0;
    foreach my $indel (@$indels) {
      if($exon->containsCoordinate($indel->{pos})) {
	if($indel->{type} eq "I") { $netIndel+=$indel->{len} }
	else { $netIndel-=$indel->{len} }
	if($indel->{len}%3 != 0) { $hasFrameshiftIndel=1 }
      }
    }
    if($hasFrameshiftIndel) {
      my $mod=$netIndel%3;
      next unless $mod==0;
      #print "$netIndel\t$mod\n";
      foreach my $indel (@$indels) {
	if($exon->containsCoordinate($indel->{pos})) {
	  print $indel->{len} . $indel->{type} . "\n";
	}
      }
      print "===========================\n";
    }
  }
  undef $indels;
}



sub parseCigar
{
  my ($cigar)=@_;
  my $array=[];
  open(CIGAR,"/home/bmajoros/cia/collapse-cigar.pl $cigar|") || die;
  <CIGAR>;
  while(<CIGAR>) {
    chomp; my @fields=split; next unless @fields>=5;
    my ($refPos,$altPos,$len,$bp,$type)=@fields;
    $type=($type eq "insertion" ? "I" : "D");
    my $rec={pos=>$altPos,len=>$len,type=>$type};
    push @$array,$rec;
  }
  close(CIGAR);
  return $array;
}





