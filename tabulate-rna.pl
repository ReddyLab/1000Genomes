#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name /path/individual/RNA/stringtie.gff\n" unless @ARGV==1;
my ($infile)=@ARGV;
$infile=~/([^\/]+)\/RNA\/stringtie.gff/ || die "can't parse path $infile\n";
my $indiv=$1;

print "indiv\tallele\tgene\ttranscript\tcov\tFPKM\tTPM\n";
my %seen;
open(IN,$infile) || die $infile;
while(<IN>) {
  if(/reference_id\s+\"([^\"]+)_(\d)\";\s+ref_gene_id\s+\"(\S+)_\d\";\s*cov\s+"([^"]+)";\s+FPKM\s*\"([^\"]+)\";\s*TPM\s+\"([^\"]+)\"/) {
    my ($transcript,$allele,$gene,$cov,$FPKM,$TPM)=($1,$2,$3,$4,$5,$6);
    next unless $cov>0;
    my $key="$transcript\t$gene\t$indiv\t$allele";
    next if $seen{$key};
    print "$indiv\t$allele\t$gene\t$transcript\t$cov\t$FPKM\t$TPM\n";
    $seen{$key}=1;
  }
}
close(IN);
print "[done]\n";

