#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <min-FPKM>\n" unless @ARGV==1;
my ($MIN_FPKM)=@ARGV;

# Globals
my $REQUIRE_NMD=1; # look only at transcripts w/NMD in at least one person?
my $SMALLEST_FPKM=0.000001; # detection limit
my $PSEUDOCOUNT=$SMALLEST_FPKM/2; # avoid taking log of zero
my $MIN_SAMPLE_SIZE=30;
#my $MIN_FPKM=0.1;
my $log2=log(2);
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $NMD_TRANSCRIPTS="$ASSEMBLY/nmd-transcripts-new.txt";
my %xy; # genes on X/Y chromosomes
my %expressed; # transcripts expressed in LCLs
my %nmdTranscripts; # transcripts having NMD in at least one individual
loadNMD($NMD_TRANSCRIPTS,\%nmdTranscripts);
loadXY("$ASSEMBLY/xy.txt",\%xy);
loadExpressed("$ASSEMBLY/expressed.txt",\%expressed);

# Process each individual
print "\"alleles\",\"fpkm\",\"transcript\"\n";
my @indivs=`ls $ASSEMBLY/combined`;
foreach my $indiv (@indivs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  my $dir="$COMBINED/$indiv";
  my $RNA_FILE="$dir/RNA/tab.txt";
  next unless -e $RNA_FILE;
  my %alleleCounts;
  updateAlleleCounts("$dir/1-inactivated.txt",\%alleleCounts);
  updateAlleleCounts("$dir/2-inactivated.txt",\%alleleCounts);
  processRNA($RNA_FILE,\%alleleCounts,\%xy,\%expressed);
}



#======================================================================
sub processRNA
{
  my ($filename,$alleleCounts,$xy,$expressed)=@_;
  open(IN,$filename) || die $filename;
  <IN>; # header line
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=7;
    my ($indiv,$allele,$gene,$transcript,$cov,$fpkm,$tpm)=@fields;
    next if($xy->{$gene}); # ignore sex chromosomes, due to ploidy issues
    if($REQUIRE_NMD) { next unless $nmdTranscripts{$transcript} }
    my $mean=$expressed->{$transcript};
    next unless $mean>0; # only consider genes expressed in this cell type
    next if $transcript=~/ALT/; # ignore aberrant splicing
    my $count=2-$alleleCounts->{$transcript}; # recode as #functional alleles
    my $log=log($fpkm+$PSEUDOCOUNT)/$log2;
    print "$count,$log,$transcript\n";
  }
  close(IN);
}
#======================================================================
sub updateAlleleCounts
{
  my ($filename,$hash)=@_;
  my %duplicates;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$what,$why)=@fields;
    next unless $what eq "NMD" && $why eq "NEWSTART";
    next if $duplicates{$transcript};
    $duplicates{$transcript}=1;
    ++$hash->{$transcript};
  }
  close(IN);
}
#======================================================================
sub loadXY
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=3;
    my ($chr,$gene,$transcript)=@fields;
    $hash->{$gene}=1;
  }
  close(IN);
}
#======================================================================
sub loadExpressed
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$mean,$sampleSize)=@fields;
    next unless $mean>=$MIN_FPKM && $sampleSize>=$MIN_SAMPLE_SIZE;
    $hash->{$transcript}=$mean;
  }
  close(IN);
}
#======================================================================
sub loadNMD
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp;
    $hash->{$_}=1;
  }
  close(IN);
}
#======================================================================
#======================================================================
#======================================================================
#======================================================================



