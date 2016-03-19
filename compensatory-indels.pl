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
  #next if $report->mappedNMD(50);
  next if $elem->findDescendent("premature-stop");
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
      if($exon->containsCoordinate($indel->{altPos})) {
	if($indel->{type} eq "I") { $netIndel+=$indel->{len} }
	else { $netIndel-=$indel->{len} }
	if($indel->{len}%3 != 0) { $hasFrameshiftIndel=1 }
      }
    }
    if($hasFrameshiftIndel) {
      my $mod=$netIndel%3;
      next unless $mod==0;
      my ($begin,$end);
      my $refPositions;
      foreach my $indel (@$indels) {
	next unless $exon->containsCoordinate($indel->{altPos});
	my $indelBegin=$indel->{altPos};
	my $len=$indel->{type} eq "I" ? $indel->{len} : 0;
	my $indelEnd=$indel->{altPos}+$len;
	if(!defined($begin) || $indelBegin<$begin) { $begin=$indelBegin }
	if(!defined($end) || $indelEnd>$end) { $end=$indelEnd }
	if($refPositions ne "") { $refPositions.="," }
	$refPositions.=$indel->{refPos};
	#print $indel->{altPos} . "\t" . $indel->{len} . $indel->{type} . "\n";
      }
      my $frameshiftLen=$end-$begin;
      print "$frameshiftLen\t$refPositions\n";
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
    my $rec={refPos=>$refPos,altPos=>$altPos,len=>$len,type=>$type};
    push @$array,$rec;
  }
  close(CIGAR);
  return $array;
}





