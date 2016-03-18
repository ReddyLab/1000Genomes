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
  my $report=new EssexFBI($essexReportElem);
  next unless $report->getStatusString() eq "mapped";
  my $substrate=$report->getSubstrate();
  my $transcriptID=$report->getTranscriptID();
  my $cigar=$report->getCigar();
  my $transcript=$report->getMappedTranscript();

  my $indels=parseCigar($cigar);

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
    my $rec={pos=>$pos,len=>$len,type=>$type};
    push @$array,$rec;
  }
  close(CIGAR);
  return $array;
}





