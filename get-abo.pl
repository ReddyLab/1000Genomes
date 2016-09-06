#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use FastaReader;
use Transcript;
use Translation;

my $ABO="ENSG00000175164.9";

my $name=ProgramName::get();
die "$name <indiv> <hap> <in.fasta> <in.essex>\n" unless @ARGV==4;
my ($indiv,$hap,$fastaFile,$essexFile)=@ARGV;

my $aboChunk;
my $reader=new FastaReader($fastaFile);
while(1) {
  my ($def,$seqRef)=$reader->nextSequenceRef();
  last unless $def;
  $def=~/^>(\S+)/ || $die $def;
  next unless $id eq $ABO;
  $aboChunk=$$seqRef;
  $reader->close();
  last;
}
my $L=length($aboChunk);
die unless $L>0;

my $aboElem;
my $parser=new EssexParser($essexFile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $geneID=$root->getAttribute("gene-ID");
  next unless $geneID eq $ABO;
  $aboElem=$root;
  last;
}

my $noncodingToCoding=$root->pathQuery("report/status/noncoding-to-coding");
die "no noncoding-to-coding" unless $noncodingToCoding;
my $transcriptNode=$noncodingToCoding->findChild("transcript");
die "no transcript" unless $transcriptNode;
my $transcript=new Transcript($transcriptNode);
my $splicedSeq=$transcript->loadTranascriptSeq(\$aboChunk);
my $protein=Translation::translate(\$splicedSeq);
my $strand=$transcript->getStrand();
my $numExons=$transcript->numExons();
print "$indiv\t$hap\t$protein\t$splicedSeq\t$strand\t$numExons\t";
for(my $i=0 ; $i<$numExons ; ++$i) {
  my $exon=$transcript->getIthExon($i);
  my $begin=$exon->getBegin(); my $end=$exon->getEnd();
  print "$begin\-$end";
  if($i+1<$numExons) { print "," }
}
print "\n";


