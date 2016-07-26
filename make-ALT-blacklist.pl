#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;
$|=1;

my $name=ProgramName::get();
die "$name <indiv> <hap> <in.essex> <ALT|SIM> <outfile>\n" unless @ARGV==5;
my ($indiv,$hap,$infile,$PREFIX,$outfile)=@ARGV;

my (%altHash,%mappedHash);
open(OUT,">$outfile") || die "can't write to file: $outfile";
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $status=$root->findChild("status");
  #next if $status->hasDescendentOrDatum("bad-annotation");
  #next if $status->hasDescendentOrDatum("too-many-vcf-errors");
  my $fbi=new EssexFBI($root);
  my $ALTs=$fbi->getAltTranscripts();
  next unless @$ALTs>0;
  my $refTranscript=$fbi->getRefTranscript();
  my $transcriptID=$fbi->getTranscriptID();
  #next if $seen{$transcriptID};
  my $chr=$refTranscript->getSubstrate();
  my $geneID=$fbi->getGeneID();
  my $mappedTranscript=$fbi->getMappedTranscript();
  my $key=hash($mappedTranscript);
  $mappedHash{$key}=$transcriptID;
  my $hits=$altHash{$key};
  if($hits) {
    foreach my $hit (@$hits) {
      print OUT "$indiv\t$hap\t$chr\t$geneID\t$transcriptID\t$hit\n";
    }}
  my $n=@$ALTs;
  my $result;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $transcript=$ALTs->[$i];
    my $ALT_ID="$PREFIX$i\_$transcriptID";
    my $key=hash($transcript);
    push @{$altHash{$key}},$ALT_ID;
    my $hit=$mappedHash{$key};
    if($hit) {
      print OUT "$indiv\t$hap\t$chr\t$geneID\t$transcriptID\t$ALT_ID\n";
    }
  }
  #$seen{$transcriptID}=1;
}
close(OUT);

print STDERR "[done]\n";



sub hash
{
  my ($transcript)=@_;
  my $exons=$transcript->getRawExons();
  my $n=@$exons;
  my $hash=$transcript->getGeneId();
  for(my $i=0 ; $i<$n ; ++$i) {
    my $exon=$exons->[$i];
    my $begin=$exon->getBegin(); my $end=$exon->getEnd();
    $hash.=" $begin\-$end";
  }
  return $hash;
}



