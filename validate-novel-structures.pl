#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
use EssexParser;

my $name=ProgramName::get();
die "$name <path-to-indiv>\n" unless @ARGV==1;
my ($dir)=@ARGV;
my $STRINGTIE="$dir/RNA/stringtie.gff";

my $rna;#=parseRNA($STRINGTIE);
my $fbiNovel=0; my $validatedNovel=0;
parseEssex("$dir/1.essex.old");
#parseEssex("$dir/2.essex");

print "$validatedNovel out of $fbiNovel were validated by RNA\n";



#============================================
sub parseEssex
{
  my ($infile)=@_;
  my $parser=new EssexParser($infile);
  while(1) {
    my $elem=$parser->nextElem();
    last unless $elem;
    my $altStructures=$elem->findDescendents("alternate-structures");
    next unless $altStructures;
    foreach my $alt (@$altStructures) {
      my $fate=$alt->findChild("fate");
      next unless $fate;
die "ok";
      next if $fate->getIthElem(0) eq "NMD";
      ++$fbiNovel;
      my $found;
      my $transcript=new Transcript($alt);
      my $rnaStructs=$rna->{$transcript->getSubstrate()};
      foreach my $rnaStruct (@$rnaStructs) {
	if(transcriptsAreEqual($transcript,$rnaStruct)) { $found=1 }
      }
      if($found) { ++$validatedNovel }
    }
    undef $elem;
  }

}
#============================================
sub parseRNA
{
  my ($infile)=@_;
  my $bySubstrate={};
  my $reader=new GffTranscriptReader;
  my $transcripts=$reader->loadGFF($infile);
  my $numTrans=@$transcripts;
  for(my $i=0 ; $i<$numTrans ; ++$i) {
    my $transcript=$transcripts->[$i];
    my $fields=$transcript->parseExtraFields();
    my $hash=$transcript->hashExtraFields($fields);
    next if($hash->{"reference_id"}); # not novel
    my $FPKM=$hash->{"FPKM"};
    $transcript->{FPKM}=$FPKM;
    my $substrate=$transcript->getSubstrate();
    push @{$bySubstrate->{$substrate}},$transcript
  }
  return $bySubstrate;
}
#============================================
sub transcriptsAreEqual
{
  my ($trans1,$trans2)=@_;
  my $raw1=$trans1->getRawExons();
  my $raw2=$trans2->getRawExons();
  my $n1=@$raw1; my $n2=@$raw2;
  if($n1!=$n2) { return 0 }
  @$raw1=sort {$a->getBegin() <=> $b->getBegin()} @$raw1;
  @$raw2=sort {$a->getBegin() <=> $b->getBegin()} @$raw2;
  for(my $i=0 ; $i<$n1 ; ++$i) {
    my $exon1=$raw1->[$i]; my $exon2=$raw2->[$i];
    if($i+1<$n1)
      { if($exon1->getEnd()!=$exon2->getEnd()) { return 0 } }
    if($i>0)
      { if($exon1->getBegin()!=$exon2->getBegin()) { return 0 } }
  }
  undef $raw1; undef $raw2;
  return 1;
}
#============================================
#============================================
#============================================
#============================================




