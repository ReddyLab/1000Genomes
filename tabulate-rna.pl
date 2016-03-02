#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name /path/individual/RNA/stringtie.gff\n" unless @ARGV==1;
my ($infile)=@ARGV;
$infile=~/([^\/]+)\/RNA\/stringtie.gff/ || die "can't parse path $infile\n";
my $indiv=$1;

my %seen;
open(IN,$infile) || die $infile;
while(<IN>) {
  if(/reference_id\s+\"([^\"]+)_\d\";\s+ref_gene_id\s+\"(\S+)_\d\";\s*cov\s+"([^"]+)";\s+FPKM/) {
    my ($transcript,$gene,$cov)=($1,$2,$3);
    next unless $cov>0;
    my $key="$transcript\t$gene\t$indiv";
    next if $seen{$key};
    print "$transcript\t$gene\t$indiv\n";
    $seen{$key}=1;
  }
}
close(IN);

