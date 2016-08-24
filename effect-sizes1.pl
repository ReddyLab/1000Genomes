#!/usr/bin/perl
use strict;

# Globals
my $MIN_SAMPLE_SIZE=30;
my $MIN_FPKM=1; # was 1
my $SMALLEST_FPKM=0.000001; # detection limit
my $PSEUDOCOUNT=$SMALLEST_FPKM/2; # avoid taking log of zero
my $log2=log(2);
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my %xy; # genes on X/Y chromosomes
my %expressed; # transcripts expressed in LCLs
loadXY("$ASSEMBLY/xy.txt",\%xy);
loadExpressed("$ASSEMBLY/expressed.txt",\%expressed);

# Process each individual
my (%FPKMnmd,%FPKMwild,%Nnmd,%Nwild);
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
my @transcripts=keys %FPKMnmd;
open(EFFECT,">effect-sizes.txt") || die;
open(LOG,">effect-sizes-log.txt") || die;
foreach my $transcript (@transcripts) {
  my $nmd=$FPKMnmd{$transcript}; my $numNMD=$Nnmd{$transcript};
  my $wild=$FPKMwild{$transcript}; my $numWild=$Nwild{$transcript};
  next unless $numWild>0 && $numNMD>0;
  #next unless $numWild>=10 && $numNMD>=10;
  my $meanNMD=$nmd/$numNMD;
  my $meanWild=$wild/$numWild;
  my $effect=$meanNMD/$meanWild;
  my $log=log($effect+$PSEUDOCOUNT)/$log2;
  print EFFECT "$effect\n";
  print LOG "$log\n";
}
close(EFFECT);
close(LOG);

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
    my $mean=$expressed->{$transcript};
    next unless $mean>0;
    next if $transcript=~/ALT/;
    my $count=2-$alleleCounts->{$transcript};
    if($count<2) { $FPKMnmd{$transcript}+=$fpkm; ++$Nnmd{$transcript} }
    else { $FPKMwild{$transcript}+=$fpkm; ++$Nwild{$transcript} }
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
    next unless $what eq "NMD";
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
#======================================================================
#======================================================================
#======================================================================
#======================================================================
#======================================================================



