#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in1.gff> <in2.gff> <blacklist1> <blacklist2> <NMD1> <NMD2> <in.tab.txt> $prefix\n" unless @ARGV==8;
my ($GFF1,$GFF2,$BLACKLIST1,$BLACKLIST2,$NMD1,$NMD2,$TAB,$PREFIX)=@ARGV;

# Load list of genes expressed in these cells
loadExpressed("/home/bmajoros/1000G/assembly/expressed.txt");

# Load the blacklists
my (%blacklist,%expressed);
loadBlacklist($BLACKLIST1,\%blacklist);
loadBlacklist($BLACKLIST2,\%blacklist);
loadNMD($NMD1,\%blacklist,$PREFIX);
loadNMD($NMD2,\%blacklist,$PREFIX);

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
  next unless $transcript=~/(\S\S\S)\d+_([^\"]+)/;
  next unless $1 eq $PREFIX;
  my $id="$transcript\_$allele";
  next if $blacklist{$id};
  $FPKM{$id}=$FPKM;
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
    if(/transcript_id\s+"(\S\S\S\d+_[^\"]+)"/) { 
    #if(/transcript_id\s+"\S\S\S\d+_([^\"]+)"/) {
      my $id=$1;
      next if $blacklist{$id};
      $id=~/(\S\S\S)\d+_([^\_]+)/ || die $id;

      #my $debug=0+$expressed{$2};###
      #print "expressed:\t$2\t$debug\n";###

      next unless $1 eq $PREFIX;
      next unless $expressed{$2};
      $hash->{$id}=0;
    }
  }
  close(IN);
}

sub loadBlacklist {
  my ($filename,$hash)=@_;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=6;
    my ($indiv,$allele,$chr,$gene,$transcript,$ALT)=@fields;
    $ALT=~/\S\S\S\d+_(\S+)/ || die $ALT;
    #$ALT=$1;
    my $id="$ALT\_$allele";
    #print "black: [$id]\n";
    $hash->{$id}=1;
  }
  close(IN);
}

sub loadNMD {
  my ($filename,$hash,$prefix)=@_;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=7;
    my ($indiv,$allele,$chr,$gene,$transcript,$ALT,$status)=@fields;
    $ALT=~/\S\S\S(\d+_\S+)/ || die $ALT;
    my $id="$prefix$1\_$allele";
    if($status eq "NMD") { $hash->{$id}=1 }
  }
  close(IN);
}

sub loadExpressed {
  my ($filename)=@_;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$mean,$N)=@fields;
    if($transcript=~/ALT\d+_(\S+)/) { $transcript=$1 }
    $expressed{$transcript}=1;
  }
  close(IN);
}





