#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
$|=1;

my $name=ProgramName::get();
die "$name <indiv> <hap> <in.essex> <outfile>\n" unless @ARGV==4;
my ($indiv,$hap,$infile,$outfile)=@ARGV;

my %seen;
open(OUT,">$outfile") || die "can't write to file: $outfile";
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $status=$root->findChild("status");
  next if $status->hasDescendentOrDatum("bad-annotation");
  next if $status->hasDescendentOrDatum("too-many-vcf-errors");
  my $alts=$status->findDescendent("alternate-structures");
  next unless $alts;
  my $refTrans=$root->findChild("reference-transcript");
  my $chr=$refTrans->getAttribute("substrate");
  my $geneID=$root->getAttribute("gene-ID");
  my $transcriptID=$root->getAttribute("transcript-ID");
  #next if $seen{$transcriptID};
  my $transcripts=$alts->findDescendents("transcript");
  my $n=@$transcripts;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $transcript=$transcripts->[$i];
    my $ALT_ID="ALT$i\_$transcriptID";
    my $result="OK";
    my $fate=$transcript->findDescendent("fate");
    if($fate && $fate->hasDescendentOrDatum("NMD")) { $result="NMD" }
    print OUT "$indiv\t$hap\t$chr\t$geneID\t$transcriptID\t$ALT_ID\t$result\n";
  }
  $seen{$transcriptID}=1;
}
close(OUT);

print STDERR "[done]\n";






