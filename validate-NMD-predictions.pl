#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
use EssexParser;
use EssexFBI;

my $name=ProgramName::get();
die "$name <path-to-indiv>\n" unless @ARGV==1;
my ($dir)=@ARGV;
$dir=~/([^\/]+)$/ || die $dir;
my $indiv=$1;
my $STRINGTIE="$dir/RNA/stringtie.gff";

my $transcriptIDs=loadTranscriptIDs("$dir/mapped.gff");
my $FPKMs=parseRNA($STRINGTIE);
my %NMD;
parseEssex("$dir/1.essex");
parseEssex("$dir/2.essex");

#my @IDs=keys %NMD;
#my @IDs=keys %$FPKMs;
my $n=@$transcriptIDs;
for(my $i=0 ; $i<$n ; ++$i) {
  for(my $hap=1 ; $hap<=2 ; ++$hap) {
    my $transcriptID=$transcriptIDs->[$i];
    $transcriptID.="_$hap";
    my $fpkm=0+$FPKMs->{$transcriptID};
    my $nmd=$NMD{$transcriptID};
    #my $status=$nmd ? "NMD" : "functional";
    my $status=$nmd eq "" ? "functional" : $nmd;
    my $transcriptID=$transcriptIDs->[$i];
    print "$transcriptID\t$indiv\t$status\t$fpkm\n";
  }
}




#============================================
sub parseEssex
{
  my ($infile)=@_;
  my $parser=new EssexParser($infile);
  while(1) {
    my $elem=$parser->nextElem();
    last unless $elem;
    my $report=new EssexFBI($elem);
    my $transcriptID=$report->getTranscriptID();
    my $substrate=$report->getSubstrate();
    $substrate=~/_(\d)/ || die $substrate;
    my $hap=$1;
    $transcriptID.="_$hap";
    my $geneID=$report->getGeneID();
    my $status=$report->getStatusString();
    if($status eq "mapped" && $report->mappedNMD())
      { $NMD{$transcriptID}="mapped-NMD" }
    elsif($status eq "splicing-changes" )#&& $report->allAltStructuresLOF())
      { $NMD{$transcriptID}="misspliced-NMD" }
    undef $elem; undef $report;
  }
}
#============================================
sub parseRNA
{
  my ($infile)=@_;
  my $hash={};
  my $reader=new GffTranscriptReader;
  my $transcripts=$reader->loadGFF($infile);
  my $numTrans=@$transcripts;
  for(my $i=0 ; $i<$numTrans ; ++$i) {
    my $transcript=$transcripts->[$i];
    my $fields=$transcript->parseExtraFields();
    my $hashFields=$transcript->hashExtraFields($fields);
    my $FPKM=0+$hashFields->{"FPKM"};
    my $transcriptID=$hashFields->{"reference_id"};
    next unless $transcriptID;
    #print "$transcriptID\t$FPKM\n";
    $hash->{$transcriptID}=$FPKM;
  }
  return $hash;
}
#============================================
sub loadTranscriptIDs
{
  my ($infile)=@_;
  my %hash;
  open(IN,$infile) || die $infile;
  while(<IN>) {
    if(/transcript_id=([^;]+)/) { $hash{$1}=1 }
  }
  close(IN);
  my $keys=[];
  @$keys=keys %hash;
  return $keys;
}
#============================================


