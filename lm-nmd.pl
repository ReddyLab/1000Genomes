#!/usr/bin/perl
use strict;

# Globals
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my %xy; # genes on X/Y chromosomes
my %expressed; # transcripts expressed in LCLs
loadXY("$ASSEMBLY/xy.txt",\%xy);
loadExpressed("$ASSEMBLY/expressed.txt",\%expressed);

# Process each individual
my @indivs=`ls $ASSEMBLY/combined`;
foreach my $indiv (@indivs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  my $dir="$COMBINED/$indiv";
  my %alleleCounts;
  updateAlleleCounts("$dir/1-inactivated.txt",\%alleleCounts);
  updateAlleleCounts("$dir/2-inactivated.txt",\%alleleCounts);
  invertAlleleCounts(\%alleleCounts);
  my $RNA_FILE="$dir/RNA/tab.txt";
  processRNA($RNA_FILE,\%alleleCounts);
}



#======================================================================
sub invertAlleleCounts
{
  my ($hash)=@_;
  my @keys=keys %$hash;
  my $n=@keys;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $key=$keys[$i];
    $hash{$key}=2-$hash{$key};
  }
}
#======================================================================
sub updateAlleleCounts
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$what,$why)=@fields;
    next unless $what eq "NMD";
    ++$hash->{$transcript};
  }
  close(IN);
}
#======================================================================
sub processRNA
{
  my ($filename,$hash)=@_;

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
    $hash->{$transcript}=$mean;
  }
  close(IN);
}
#======================================================================
#======================================================================
#======================================================================
#======================================================================
#======================================================================



