#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajors/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $INFILE="mapped.gff";
my $OUTFILE="reformatted.gff";

my @dirs=`ls $COMBINED`;
foreach my $dir (@$dirs) {
  chomp $dir;
  next unless $dir=~/^HG\d+$/ || $dir=~/^NA\d$/;
  my $infile="$dir/$INFILE";
  my $outfile="$dir/$OUTFILE";
  process($infile,$outfile);
}



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
    print OUT "$substrate\t$source\t$type\t$begin\t$end\t$score\t$strand\t$frame\t$extra";

#ENSG00000272636_1       ensembl internal-exon   17520   17599   0       -       2       transcript_id=ENST00000343572; gene_id=ENSG00000272636
  }
  close(OUT);
  close(IN);
}

