#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;

my $name=ProgramName::get();
die "$name <indiv-ID> <infile.essex>\n" unless @ARGV==2;
my ($indiv,$infile)=@ARGV;

chomp $infile;
$infile=~/(\d).essex$/ || die $infile;
my $hap=$1;

my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexFBI($elem);
  next unless $report->getStatusString() eq "splicing-changes";
  #next if $report->mappedNMD(50);
  next if $elem->findDescendent("premature-stop");
  my $substrate=$report->getSubstrate();
  my $transcriptID=$report->getTranscriptID();
  my $geneID=$report->getGeneID();
  my $cigar=$report->getCigar();
  my $transcript=$report->getMappedTranscript();
  my $brokenSites=$report->getBrokenSpliceSites();

  my $indels=parseCigar($cigar);
  my $numExons=$transcript->numExons();
  for(my $i=0 ; $i<$numExons ; ++$i) {
    my $exonID=$i+1;
    my $exon=$transcript->getIthExon($i);
    if(exonSkipped($exon,$brokenSites)) {
      my $netIndel=0;
      foreach my $indel (@$indels) {
	if($exon->containsCoordinate($indel->{altPos})) {
	  if($indel->{type} eq "I") { $netIndel+=$indel->{len} }
	  else { $netIndel-=$indel->{len} }
	}
      }
      if($netIndel%3!=0) {
	print "$indiv\thap$hap\t$geneID\t$transcriptID\texon$exonID\t$netIndel\n";
      }
    }
  }
  undef $indels;
}



sub exonSkipped
{
  my ($exon,$brokenSites)=@_;
  foreach my $site (@$brokenSites) {
    my ($pos,$type)=@$site;
    #print "$pos $type\t"; print $exon->getBegin() . "-" . $exon->getEnd() ."\n";
    if($type eq "GT" && $exon->getEnd()==$pos ||
       $type eq "AG" && $exon->getBegin()==$pos+2) {
      return 1;
    }
  }
  return 0;
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





