#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in1.gff> <in2.gff> <in.tab.txt>\n" unless @ARGV==3;
my ($GFF1,$GFF2,$TAB)=@ARGV;

# Process the GFF file
my %FPKM;
loadGFF($GFF1,\%FPKM);
loadGFF($GFF2,\%FPKM);

# Process the tab.txt file
open(IN,$TAB) || die "can't open $TAB";
<IN>; # header
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  next unless $transcript=~/\S\S\S\d+_([^\"]+)/;
  my $id="$1\_$allele";
  # $FPKM{"$transcript\_$allele"}=$FPKM;
  $FPKM{$id}+=$FPKM;
}
close(IN);

# Dump table to output
my @keys=keys %FPKM;
@keys=sort {$FPKM{$a} <=> $FPKM{$b}} @keys;
my $n=@keys;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$keys[$i];
  my $fpkm=$FPKM{$transcript};
  print "$transcript\t$fpkm\n";
}

print STDERR "[done]\n";

sub loadGFF {
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open $filename";
  while(<IN>) {
    #if(/transcript_id\s+"(\S\S\S\d+_[^\"]+)"/) { $hash->{$1}=0 }
    if(/transcript_id\s+"\S\S\S\d+_([^\"]+)"/) { $hash->{$1}=0 }
  }
  close(IN);
}
