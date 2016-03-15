#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
use EssexParser;
use EssexFBI;

my $name=ProgramName::get();
die "$name <path-to-indiv>\n" unless @ARGV==1;
my ($dir)=@ARGV;
my $STRINGTIE="$dir/RNA/stringtie.gff";

my $rna=parseRNA($STRINGTIE);
my $fbiNovel=0; my $validatedNovel=0; my $notReallyBroken=0;
parseEssex("$dir/1.essex");
#parseEssex("$dir/2.essex");

print "$validatedNovel out of $fbiNovel were validated by RNA\n";
print "$notReallyBroken transcripts FBI said were broken were found in RNA\n";


#============================================
sub parseEssex
{
  my ($infile)=@_;
  my $parser=new EssexParser($infile);
  while(1) {
    my $elem=$parser->nextElem(); last unless $elem;
    my $report=new EssexFBI($elem);
    my $substrate=$report->getSubstrate();
    my $transcriptID=$report->getTranscriptID();
    next unless $report->hasBrokenSpliceSite(); # broken, not just weakened!
    my $altStructures=$elem->findDescendents("alternate-structures");
    next unless $altStructures && @$altStructures>0;
    my $parent=$altStructures->[0];
    $altStructures=$parent->findChildren("transcript");
    foreach my $alt (@$altStructures) {
      my $fate=$alt->findChild("fate");
      next unless $fate;
      #next if $fate->getIthElem(0) eq "NMD";
      my $found;
      my $transcript=new Transcript($alt);
      my $transcriptIsInRNA=0;
      my $rnaTranscript=$rna->{$substrate}->{$transcriptID};
      if($rnaTranscript && $rnaTranscript->{FPKM}>0) { $transcriptIsInRNA=1 }
      my $geneIsExpressed=hasNonzeroFPKM($substrate);

#no -- i need to first tabulate a list of all genes expressed in *any* indiv?

      next unless $geneIsExpressed;
      ++$fbiNovel;
      my @rnaStructs=values %{$rna->{$substrate}}; my $rna;
      foreach my $rnaStruct (@rnaStructs)
	{ if(transcriptsAreEqual($transcript,$rnaStruct))
	    { $rna=$rnaStruct; $found=1 } }
      if($found) { ++$validatedNovel }
      #die "found" if $found; ### debugging
      if(0 && $found) {
	print "FBI PREDICTION:\n";
	print $transcript->toGff(); print "\n";
	print "RNA:\n";
	print $rna->toGff(); print "\n";
	print "ESSEX:\n";
	$elem->print(\*STDOUT);
	print "\n";
      }
      if($transcriptIsInRNA) { ++$notReallyBroken }
    }
    undef $elem;
  }

}
#============================================
sub hasNonzeroFPKM
{
  my ($substrate)=@_;
  my $hash=$rna->{$substrate};
  if($hash) {
    my @keys=keys %$hash;
    foreach my $transcriptID (@keys) {
      if($hash->{$transcriptID}->{FPKM}>0) { return 1 }
    }
  }
  return 0;
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
    my $transcriptID=$transcript->getTranscriptId();
    $bySubstrate->{$substrate}->{$transcriptID}=$transcript;
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




