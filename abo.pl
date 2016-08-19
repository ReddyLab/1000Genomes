#!/usr/bin/perl
use strict;

my $BASE="/home/bmajoros/splicing/ethnic/abo";

process("$BASE/HG00096-1.txt","$BASE/HG00096-1.gff",26855);
process("$BASE/HG00096-2.txt","$BASE/HG00096-2.gff",26799);
process("$BASE/ref.txt","$BASE/ref.gff",26830);

process2("A101.gff","A-allele.gff");
process2("B101.gff","B-allele.gff");
process2("O101.gff","O-allele.gff");

###########################################################

sub process2 {
  my ($infile,$outfile)=@_;
  open(IN,$infile) || die $infile;
  my (@exons,$L,$zero);
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=9;
    my ($chr,$source,$exon,$begin,$end,$source,$strand,$frame)=@fields;
    push @exons,[$begin,$end];
    if($begin>$L) { $L=$begin }
    if($end>$L) { $L=$end }
  }
  close(IN);
  foreach my $exon (@exons) {
    my ($begin,$end)=@$exon;
    $begin=$L-$begin; $end=$L-$end;
    ($begin,$end)=($end,$begin);
    ++$begin;
    $exon->[0]=$begin; $exon->[1]=$end;
  }
  open(OUT,">$outfile") || die $outfile;
  foreach my $exon (@exons) {
    my ($begin,$end)=@$exon;
    $begin-=$zero; $end-=$zero;
    print OUT "chr9\tsource\texon\t$begin\t$end\t0\t+\t0\ttranscript_id=1;\n";
  }
  close(OUT);
}

sub process {
  my ($infile,$outfile,$L)=@_;
  open(IN,$infile) || die $infile;
  my (@exons);
  while(<IN>) {
    next unless(/\((.+)\)/);
    $_=$1;
    chomp; my @fields=split; next unless @fields>=6;
    my ($type,$begin,$end,$score,$strand,$frame)=@fields;
    push @exons,[$begin,$end,$type];
    #if($end>$L) { $L=$end }
    #if($begin>$L) { $L=$begin }
  }
  close(IN);
  open(OUT,">$outfile") || die $outfile;
  foreach my $exon (@exons) {
    my ($begin,$end)=@$exon;
    $begin=$L-$begin; $end=$L-$end;
    ($begin,$end)=($end,$begin);
    ++$begin;
    $begin-=1000; $end-=1000;
    print OUT "chr9\tsource\texon\t$begin\t$end\t0\t+\t0\ttranscript_id=1;\n";
  }
  close(OUT);
}


