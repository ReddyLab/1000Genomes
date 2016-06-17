#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;

my $name=ProgramName::get();
die "$name <indiv-ID> <infile.essex>\n" unless @ARGV==2;
my ($indiv,$infile)=@ARGV;

chomp $infile;
$infile=~/(\d).*\.essex$/ || die $infile;
my $hap=$1;

my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexFBI($elem);
  next unless $report->getStatusString() eq "mapped";
  my $status=$elem->findChild("status");
  next unless $status;
  next if $status->findDescendent("premature-stop");
  next if $status->findDescendent("nonstop-decay");
  next if $status->findDescendent("splicing-changes");
  next if $status->findDescendent("no-transcript");
  next if $status->findDescendent("noncoding");
  next if $status->findDescendent("bad-annotation");
  my $substrate=$report->getSubstrate();
  my $transcriptID=$report->getTranscriptID();
  my $geneID=$report->getGeneID();
  my $cigar=$report->getCigar();
  my $transcript=$report->getMappedTranscript();
  my $strand=$transcript->getStrand();
  if($strand eq "-") {
    $transcript->reverseComplement($elem->getAttribute("alt-length"));
    $cigar=reverseCigar($cigar);
  }

  my $indels=parseCigar($cigar);
  my $numExons=$transcript->numExons();
  for(my $i=0 ; $i<$numExons ; ++$i) {
    my $exonID=$i+1;
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
      my $AAlen=int($frameshiftLen/3);
      print "$indiv\thap$hap\t$geneID\t$transcriptID\texon$exonID\t$AAlen\t$refPositions\n";
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




sub reverseCigar
{
  my ($cigar)=@_;
  my $rev;
  while($cigar=~/^(\d+\D)(.*)/) { $rev="$1$rev"; $cigar=$2 }
  return $rev;
}

