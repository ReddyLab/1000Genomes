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
  next unless $status->findDescendent("frameshift");
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
  my $hasFrameshiftIndel;
  foreach my $indel (@$indels) {
    if($indel->{len}%3 && inExon($indel,$transcript))
      { $hasFrameshiftIndel=1 }}
  next unless $hasFrameshiftIndel;
#print "$transcriptID has frameshift indel\n";
  my $refPos;  my $numIndels=@$indels;
  for(my $i=0 ; $i<$numIndels ; ++$i) {
    my $indel=$indels->[$i];
    next unless $indel->{len}%3!=0 && inExon($indel,$transcript);
    my $frame=$indel->{len}%3;
    $refPos=$indel->{refPos};
    for(my $j=$i+1 ; $j<$numIndels ; ++$j) {
      my $next=$indels->[$j];
      next unless $next->{len}%3!=0 && inExon($next,$transcript);
      if($next->{type} eq "I") { $frame=($frame+$next->{len})%3 }
      else { $frame=($frame+3-$next->{len})%3 }
      $refPos.=",".$next->{refPos};
      if($frame==0) {
	my $frameshiftLen=nucleotidesAffected($indel->{altPos},
					      getIndelEnd($next),$transcript);
	my $AAlen=int($frameshiftLen/3);
	print "$indiv\thap$hap\t$geneID\t$transcriptID\t$AAlen\t$refPos\n";
	$i=$j;
	last;
      }
    }
  }
  undef $indels;
}

sub getIndelEnd
{
  my ($indel)=@_;
  my $len=$indel->{type} eq "I" ? $indel->{len} : 0;
  return $indel->{altPos}+$len;
}

sub inExon
{
  my ($indel,$transcript)=@_;
  my $numExons=$transcript->numExons();
  for(my $i=0 ; $i<$numExons ; ++$i) {
    if($transcript->getIthExon($i)->containsCoordinate($indel->{altPos}))
      { return 1 }
  }
  return 0;
}

sub nucleotidesAffected
{
  my ($begin,$end,$transcript)=@_;
  my $affected=0;
  my $numExons=$transcript->numExons();
  for(my $i=0 ; $i<$numExons ; ++$i) {
    my $exon=$transcript->getIthExon($i);
    if($exon->containsCoordinate($begin)) {
      if($exon->containsCoordinate($end)) { $affected+=$end-$begin }
      else {
	$affected+=$exon->getEnd()-$begin;
	for( ++$i ; $i<$numExons ; ++$i) {
	  $exon=$transcript->getIthExon();
	  if($exon->containsCoordinate($end)) {
	    $affected+=$end-$exon->getBegin();
	    last }
	  else { $affected+=$exon->getLength() }}}
      last }}
  return $affected;
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


