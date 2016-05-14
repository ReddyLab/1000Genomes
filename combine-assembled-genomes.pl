#!/usr/bin/perl
use strict;
use FastaReader;
use FastaWriter;
use GffTranscriptReader;
use ProgramName;

my $name=ProgramName::get();
die "$name individuals.txt\n" unless @ARGV==1;
my ($indivFile)=@ARGV;

# Parallelize by sets of individuals
my %individuals;
open(IN,$indivFile) || die "can't open $indivFile\n";
while(<IN>) {
  chomp;
  next unless(/\S/);
  $individuals{$_}=1;
}
close(IN);

# Globals
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $BASEDIR="$ASSEMBLY/fasta";
my $OUTDIR="$ASSEMBLY/combined";
#my $GFF="$ASSEMBLY/genes-all-10.gff";
my $GFF="$ASSEMBLY/genes-all-30.gff";
my $writer=new FastaWriter;
#my @dirs=(0,1,2,3,4,5,6,7,8,9);
my @dirs;
for(my $i=0 ; $i<30 ; ++$i) { push @dirs,$i }

# Load error/warning list
my (%warnings,%errors);
foreach my $subdir (@dirs) {
  open(IN,"$BASEDIR/$subdir/errors.txt") || die;
  while(<IN>) {
    chomp;
    my @fields=split;
    next unless @fields>=6;
    next unless(/^VCF/);
    my ($severity,$type,$indiv,$gene)=@fields;
    $gene=~s/_1/_2/g;
    $gene=~s/_0/_1/g;
    my $key="$indiv $gene";
    if($severity=~/WARNING/) { ++$warnings{$key} }
    elsif($severity=~/ERROR/) { ++$errors{$key} }
  }
  close(IN);
}

# Get list of nonredundant genes
my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($GFF); # ordered along chrom
my $numTrans=@$transcripts;
my ($prevTrans,%keep);
for(my $i=0 ; $i<$numTrans ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $chr=$transcript->getSubstrate();
  if($prevTrans && $prevTrans->getSubstrate() eq $chr &&
     $prevTrans->overlaps($transcript)) { next }
  $keep{$transcript->getGeneId()}=1;
  $prevTrans=$transcript;
}

# Combine output files into one FASTA per individual
my @files=`ls $BASEDIR/0/*-1.fasta`;
foreach my $file (@files) {
  chomp $file;
  $file=~/\/([^\/]+)-1.fasta/ || die;
  my $ID=$1;
  next unless $individuals{$ID}; # Parallelize by sets of individuals
  System("cd $OUTDIR ; mkdir $ID");
  my $outdir="$OUTDIR/$ID";

  # Process 1.fasta
  open(OUT,">$outdir/1.fasta") || die;
  foreach my $subdir (@dirs) 
    { append("$BASEDIR/$subdir/$ID-1.fasta",\*OUT,$ID,1) }
  close(OUT);

  # Process 2.fasta
  open(OUT,">$outdir/2.fasta") || die;
  foreach my $subdir (@dirs) 
    { append("$BASEDIR/$subdir/$ID-2.fasta",\*OUT,$ID,2) }
  close(OUT);
}

sub System {
  my ($cmd)=@_;
  #print "$cmd\n\n";
  system($cmd);
}

sub append
{
  my ($filename,$out,$ID,$haplotype)=@_;
  my $reader=new FastaReader($filename);
  while(1) {
    my ($defline,$seqRef)=$reader->nextSequenceRef();
    last unless $defline;
    $defline=~/^>(\S+)_\d( \/coord=\S+ \/margin=\d+ \/cigar=\S+) \/warnings=\d+ \/errors=\d+(.*)/ || die "Can't parse defline: $defline";
    my ($gene,$rest1,$rest2)=($1,$2,$3);
    next unless $keep{$gene};
    #if($ID ne "ref") {$gene.="_$haplotype"}
    $gene.="_$haplotype";
    my $key="$ID $gene";
    my $numWarn=0+$warnings{$key};
    my $numErr=0+$errors{$key};
    $defline=">$gene$rest2 /warnings=$numWarn /errors=$numErr\n";
    #$defline=">$gene$rest2\n";
    $writer->addToFastaRef($defline,$seqRef,$out);
  }
  $reader->close();
}






