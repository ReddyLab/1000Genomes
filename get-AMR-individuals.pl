#!/bin/env perl
use strict;
use ProgramName;
$|=1;

# Globals
my $PROB_KEEP_VARIANT=0.01; # thinning, for efficiency
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $VCF="$THOUSAND/vcf";
my $HAPMIX="/home/bmajoros/hapmix";
my $INTERPOLATED="$HAPMIX/data-prep/interpolated";
my $PRECISION=10**8;

# Load ethnicities
my %ethnicity;
open(IN,"$VCF/gender-and-ancestry.txt") || die;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($indiv,$sex,$subpop,$ethnicity)=@fields;
  $ethnicity{$indiv}=$ethnicity; }
close(IN);


# Process each VCF file in turn
my @files=`ls $VCF/ALL.*.vcf.gz`;
foreach my $file (@files) {
  chomp $file;
  $file=~/\/ALL\.chr([^\.]+)\./ || die $file;
  my $chr=$1;
  next if $chr eq "X" || $chr eq "Y";

  # Process VCF
  open(VCF,"cat $file | gunzip |") || die "can't open $file\n";
  while(<VCF>) {
    chomp; my @fields=split; next unless @fields>=9;
    if($fields[0] eq "#CHROM") {
      for(my $i=0;$i<9;++$i) { shift @fields }
      my $index=0;
      foreach my $indiv (@fields) {
	my $ethnicity=$ethnicity{$indiv};
	if($ethnicity eq "AMR") { print "$index\t$indiv\n"; ++$index }
      }
      last
    }
  }
  last
}






