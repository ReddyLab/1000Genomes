


OBSOLETE?




#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexICE;

my $name=ProgramName::get();
die "$name <indiv-ID> <infile.essex>\n" unless @ARGV==2;
my ($indiv,$infile)=@ARGV;

chomp $infile;
$infile=~/(\d).*\.essex$/ || die $infile;
my $hap=$1;

my (%indelLengths);
my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexICE($elem);
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
  my $refLen=$elem->getAttribute("ref-length");
  my $altLen=$elem->getAttribute("alt-length");
  my $transcriptID=$report->getTranscriptID();
  my $geneID=$report->getGeneID();
  my $cigar=$report->getCigar();
  my $transcript=$report->getMappedTranscript();
  my $strand=$transcript->getStrand();
  if($strand eq "-") {
    $transcript->reverseComplement($elem->getAttribute("alt-length"));
    $cigar=reverseCigar($cigar) }
  my $indels=parseCigar($cigar);
  shuffle($indels,$refLen,$altLen);
  my $hasFrameshiftIndel;
  foreach my $indel (@$indels) {
    if(inExon($indel,$transcript)) {
      my $refPos=$indel->{refPos};
      my $id="$geneID\@$refPos";
      $indelLengths{$id}=$indel->{len};
      if($indel->{len}%3) { $hasFrameshiftIndel=1 }
    }
  }
  next unless $hasFrameshiftIndel;
  my $refPos;  my $numIndels=@$indels;
  for(my $i=0 ; $i<$numIndels ; ++$i) {
    my $indel=$indels->[$i];
    next unless $indel->{len}%3!=0 && inExon($indel,$transcript);
    my $frame=$indel->{type} eq "I" ? $indel->{len}%3 : -$indel->{len}%3;
    $refPos=printIndel($indel);
    for(my $j=$i+1 ; $j<$numIndels ; ++$j) {
      my $next=$indels->[$j];
      next unless $next->{len}%3!=0 && inExon($next,$transcript);
      if($next->{type} eq "I") { $frame=($frame+$next->{len})%3 }
      else { $frame=($frame-$next->{len})%3 }
      if($frame<0) { $frame=($frame+3)%3 }
      $refPos.=",".printIndel($next);
      if($frame==0) {
	my $frameshiftLen=nucleotidesAffected($indel->{altPos},
					      getIndelEnd($next),$transcript);
	my $AAlen=int(($frameshiftLen+2)/3);
	if($AAlen<0) { $AAlen=0 }
	print "$indiv\thap$hap\t$geneID\t$transcriptID\t$AAlen\t$refPos\n";
	$i=$j;
	last;
      }
    }
    if($frame%3) { print "NOT CORRECTED: $indiv\thap$hap\t$geneID\t$transcriptID\t".printIndel($indel)."\n" }
  }
  undef $indels;
}
my @lengths=values %indelLengths;
foreach my $len (@lengths) { print "LENGTH $len\n" }
print "[done]\n";

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
    if($transcript->getIthExon($i)->containsCoordinate($indel->{altPos})) {
      $indel->{exon}=$i+1;
      return 1;
    }
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

sub printIndel
{
  my ($indel)=@_;
  return $indel->{refPos}."=".$indel->{len}.$indel->{type}
    ."(exon".$indel->{exon}.")";
}

sub parseCigar
{
  my ($cigar)=@_;
  my $array=[]; my $ref=0; my $alt=0;
  while(length($cigar)>0) {
    $cigar=~/^(\d+)([MID])(.*)/ || die $cigar;
    my ($L,$op,$rest)=($1,$2,$3);
    if($op eq "M") { $ref+=$L; $alt+=$L }
    elsif($op eq "I") {
      my $rec={refPos=>$ref,altPos=>$alt,len=>$L,type=>$op};
      push @$array,$rec;
      $alt+=$L }
    elsif($op eq "D") {
      my $rec={refPos=>$ref,altPos=>$alt,len=>$L,type=>$op};
      push @$array,$rec;
      $ref+=$L }
    $cigar=$rest;
  }
  return $array;
}

sub shuffle
{
  my ($array,$refLen,$altLen)=@_;
  my $N=@$array;
  for(my $i=0 ; $i<$N-1 ; ++$i) {
    my $indel=$array->[$i];
    #$indel->{refPos}=int(rand($refLen));
    #$indel->{altPos}=int(rand($altLen));
    my $j=$i+int(rand($N-$i));
    my $other=$array->[$j];
    my $len=$other->{len};
    $other->{len}=$indel->{len};
    $indel->{len}=$len;
  }
  #@$array=sort {$a->{altPos} <=> $b->{altPos}} @$array;
}

sub reverseCigar
{
  my ($cigar)=@_;
  my $rev;
  while($cigar=~/^(\d+\D)(.*)/) { $rev="$1$rev"; $cigar=$2 }
  return $rev;
}


