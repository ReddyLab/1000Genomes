#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <input.gff> <output.gff>\n" unless @ARGV==2;
my ($infile,$outfile)=@ARGV;

process($infile,$outfile);


sub process
{
  my ($infile,$outfile)=@_;
  open(IN,$infile) || die $infile;
  open(OUT,">$outfile") || die $outfile;
  while(<IN>) {
    chomp;
    my @fields=split/\t/;
    next unless @fields>=8;
    my ($substrate,$source,$type,$begin,$end,$score,$strand,$frame,$extra)=
      @fields;
    $substrate=~/\S+_(\d)/ || die $substrate;
    my $hap=$1;
    $extra=~/(.*)gene_id=([^;\s]+)(.*)/ || die $extra;
    my ($left,$id,$right)=($1,$2,$3);
    $extra="${left}gene_id \"${id}_$hap\"$right";
    $extra=~/(.*)transcript_id=([^;\s]+)(.*)/ || die $extra;
    my ($left,$id,$right)=($1,$2,$3);
    $extra="${left}transcript_id \"${id}_$hap\"$right";
    if($type=~/exon/) { $type="exon" }
    print OUT "$substrate\t$source\t$type\t$begin\t$end\t$score\t$strand\t$frame\t$extra\n";
  }
  close(OUT);
  close(IN);
}

