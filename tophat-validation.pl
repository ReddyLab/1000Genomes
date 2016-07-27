#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;

my $name=ProgramName::get();
die "$name <in.gff> <junctions.bed> <prefix=ALT|SIM>\n" unless @ARGV==3;
my ($gffFile,$junctionsFile,$PREFIX)=@ARGV;

# Load the TopHat junctions file
my $introns=parseTophat($junctionsFile);

# Load the GFF file
my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($gffFile);
my $transcriptHash=hashTranscriptIDs($transcripts);

# Process all ALT/SIM structures
my $n=@$transcripts;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $id=$transcript->getTranscriptId();
  next unless $id=~/(\S\S\S)\d+_(\S+)/;
  next unless $1 eq $PREFIX;
  my $parentID=$2;
  my $parent=$transcriptHash->{$parentID};
  die $parentID unless $parent;
  my $geneID=$transcript->getGeneId();
  my $geneIntrons=$introns->{$geneID};
  if(!$geneIntrons) { $geneIntrons=[] }
  if($transcript->numExons()<$parent->numExons())
    { exonSkipping($transcript,$parent,$geneIntrons) }
  else { crypticSplicing($transcript,$parent,$geneIntrons) }
}

# Terminate
print STDERR "[done]\n";



#########################################################################
#########################################################################

sub exonSkipping {
  my ($child,$parent)=@_;
  my $numChildExons=$child->numExons(); my $numParentExons=$parent->numExons();
  die "$numChildExons vs $numParentExons"
    unless $numChildExons==$numParentExons-1;

}


sub crypticSplicing {
  my ($child,$parent)=@_;
  my $numChildExons=$child->numExons(); my $numParentExons=$parent->numExons();
  die "$numChildExons vs $numParentExons"
    unless $numChildExons==$numParentExons;

}


sub hashTranscriptIDs {
  my ($transcripts)=@_;
  my $hash={};
  my $n=@$transcripts;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $transcript=$transcripts->[$i];
    my $id=$transcript->getTranscriptId();
    $hash->{$id}=$transcript;
  }
  return $hash;
}


sub parseTophat {
  my ($filename)=@_;
  my $introns={};
  open(IN,$filename) || die "Can't open $filename";
  <IN>; # header
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=10;
    my ($gene,$begin,$end,$junc,$reads,$strand,$b,$e,$color,$two,$overhangs)=
      @fields;
    $overhangs=~/(\d+),(\d+)/ || die $overhangs;
    my $donor=$begin+$1; my $acceptor=$end-$2;
    my $record=[$donor,$acceptor];
    push @{$introns->{$gene}},$record;
  }
  close(IN);
}





