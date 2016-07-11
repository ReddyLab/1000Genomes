#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $CHROMFILE="$ASSEMBLY/gencode-chromosomes.txt";

my %chr;
open(IN,$CHROMFILE) || die $CHROMFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($gene,$chr)=@fields;
  $chr{$gene}=$chr;
}
close(IN);

my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir/RNA";
  next unless -e "$dir/readcounts.txt";
  filter("$dir/readcounts.txt","$dir/readcounts-filtered.txt");
  my $ref="$dir/ref";
  filter("$ref/readcounts.txt","$ref/readcounts-filtered.txt");
}


sub filter
{
  my ($infile,$outfile)=@_;
  my $total=0;
  open(IN,$infile) || die $infile;
  open(OUT,">$outfile") || die $outfile;
  while(<IN>) {
    next if(/TOTAL/);
    chomp; my @fields=split; next unless @fields>=2;
    my ($gene,$count)=@fields;
    $gene=~/(\S+)_\d/ || die $gene;
    $gene=$1;
    my $chr=$chr{$gene};
    next if($chr eq "chrX" || $chr eq "chrY");
    print OUT "$gene\t$count\n";
    $total+=$count;
  }
  print OUT "TOTAL AUTOSOMAL READS:\t$total";
  close(OUT);
  close(IN);
}



