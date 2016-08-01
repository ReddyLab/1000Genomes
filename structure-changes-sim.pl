#!/usr/bin/perl
use strict;
use EssexParser;
use EssexFBI;
use ProgramName;
$|=1;

my $name=ProgramName::get();
die "$name <in.essex> <outfile> <indiv> <allele#> <blacklist>\n" unless @ARGV==5;
my ($infile,$outfile,$indiv,$hap,$blacklist)=@ARGV;

my %blacklist;
loadBlacklist($blacklist,\%blacklist);

my %seen;
open(OUT,">$outfile") || die "can't write to file: $outfile\n";
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $fbi=new EssexFBI($root);
  my $transcriptID=$fbi->getTranscriptID();
  next if $seen{$transcriptID};
  $seen{$transcriptID}=1;
  my $geneID=$fbi->getGeneID();
  my $status=$fbi->getStatusString();
  if($status eq "splicing-changes") {
    my $altStructs=$root->pathQuery("report/status/alternate-structures");
    my $numTrans=$altStructs->numElements();
    for(my $i=0 ; $i<$numTrans ; ++$i) {
      my $transcript=$altStructs->getIthElem($i);
      next unless $transcript->getAttribute("source") eq "SIMULATION";
      my $id=$transcript->getAttribute("ID");
      $id="SIM$i\_$id";
      my $key="$hap $id";
      next if($blacklist{$key});
      my $structChange=$transcript->findChild("structure-change");
      my $numElem=$structChange->numElements();
      for(my $i=0 ; $i<$numElem ; ++$i) {
	my $child=$structChange->getIthElem($i);
	if(!EssexNode::isaNode($child)) {
	  print OUT "$indiv\t$hap\t$geneID\t$id\t$child\n";
	}
      }
    }
  }
  undef $root; undef $fbi;
}
close(OUT);

print STDERR "[done]\n";




sub loadBlacklist
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open $filename";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=6;
    my ($indiv,$hap,$chr,$gene,$mappedTranscript,$sim)=@fields;
    my $key="$hap $sim";
    $hash->{$key}=1;
  }
  close(IN);
}
