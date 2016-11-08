#!/usr/bin/perl
use strict;

# Globals
my $MIN_SAMPLE_SIZE=30;
my $MIN_FPKM=3; # was 1
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
my (%FPKMnmd0,%FPKMnmd1,%FPKMwild,%Nnmd0,%Nnmd1,%Nwild);
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
my @transcripts=keys %FPKMwild;
open(EFFECT0,">effect-sizes-homo.fpkm3") || die;
open(EFFECT1,">effect-sizes-het.fpkm3") || die;
open(LOG0,">effect-sizes-log-homo.fpkm3") || die;
open(LOG1,">effect-sizes-log-het.fpkm3") || die;
foreach my $transcript (@transcripts) {
  my $nmd0=$FPKMnmd0{$transcript}; my $numNMD0=$Nnmd0{$transcript};
  my $nmd1=$FPKMnmd1{$transcript}; my $numNMD1=$Nnmd1{$transcript};
  my $wild=$FPKMwild{$transcript}; my $numWild=$Nwild{$transcript};
  next unless $numWild>0; # >10 ?
  my $meanWild=$wild/$numWild;
  if($numNMD0>0) {
    my $meanNMD=$nmd0/$numNMD0;
    my $effect=$meanNMD/$meanWild;
    my $log=log($effect+$PSEUDOCOUNT)/$log2;
    print EFFECT0 "$effect\n";
    print LOG0 "$log\n";
  }
  if($numNMD1>0) {
    my $meanNMD=$nmd1/$numNMD1;
    my $effect=$meanNMD/$meanWild;
    my $log=log($effect+$PSEUDOCOUNT)/$log2;
    print EFFECT1 "$effect\n";
    print LOG1 "$log\n";
  }
}
close(EFFECT0); close(EFFECT1);
close(LOG0); close(LOG1);

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
    if($count==0) { $FPKMnmd0{$transcript}+=$fpkm; ++$Nnmd0{$transcript} }
    elsif($count==1) { $FPKMnmd1{$transcript}+=$fpkm; ++$Nnmd1{$transcript} }
    elsif($count==2) { $FPKMwild{$transcript}+=$fpkm; ++$Nwild{$transcript} }
    else { die }
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



