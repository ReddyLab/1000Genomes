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
my $OUTDIR="$HAPMIX/data-prep/ref";
my $INTERPOLATED="$HAPMIX/data-prep/interpolated";
my $PRECISION=10**8;

# Load ethnicities
print "Loading ethnicities\n";
my %ethnicity;
open(IN,"$VCF/gender-and-ancestry.txt") || die;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($indiv,$sex,$subpop,$ethnicity)=@fields;
  $ethnicity{$indiv}=$ethnicity; }
close(IN);


# Process each VCF file in turn
my @header;
my @files=`ls $VCF/ALL.*.vcf.gz`;
foreach my $file (@files) {
  chomp $file;
  print "Processing $file\n";
  $file=~/\/ALL\.chr([^\.]+)\./ || die $file;
  my $chr=$1;
  next if $chr eq "X" || $chr eq "Y";

  # Load genetic positions (centimorgans)
  print "Loading genetic positions\n";
  my $interpolated=loadGeneticPos($chr);

  # Open output files
  open(EURsnpfile,">$OUTDIR/EURsnpfile.$chr") || die;
  open(AMRsnpfile,">$OUTDIR/AMRsnpfile.$chr") || die;
  open(AFRsnpfile,">$OUTDIR/AFRsnpfile.$chr") || die;
  open(EASsnpfile,">$OUTDIR/EASsnpfile.$chr") || die;
  open(SASsnpfile, ">$OUTDIR/SASsnpfile.$chr") || die;
  open(EURgenofile,">$OUTDIR/EURgenofile.$chr") || die;
  open(AMRgenofile,">$OUTDIR/AMRgenofile.$chr") || die;
  open(AFRgenofile,">$OUTDIR/AFRgenofile.$chr") || die;
  open(EASgenofile,">$OUTDIR/EASgenofile.$chr") || die;
  open(SASgenofile, ">$OUTDIR/SASgenofile.$chr") || die;
  open(VCF,"cat $file | gunzip |") || die "can't open $file\n";
  while(<VCF>) {
    chomp; my @fields=split; next unless @fields>=9;
    if($fields[0] eq "#CHROM") {
      for(my $i=0;$i<9;++$i) { shift @fields }
      @header=@fields; }
    elsif(/#/) { next }
    else {
      my ($chr,$pos,$variant,$ref,$alt)=@fields;
      if($variant eq ".") { $variant="chr$chr\@$pos" }
      next unless length($ref)==1 && length($alt)==1;
      if($chr=~/chr(\S+)/) { $chr=$1 }
      my $centimorgans=$interpolated->{$pos};
      next unless $centimorgans>0;
      next unless rand(1)<=$PROB_KEEP_VARIANT;
      #print "$chr\t$pos\t$centimorgans\t$variant\t$ref\t$alt\n";
      print EURsnpfile "\t$variant\t$chr\t$centimorgans\t$pos\t$ref\t$alt\n";
      print AMRsnpfile "\t$variant\t$chr\t$centimorgans\t$pos\t$ref\t$alt\n";
      print AFRsnpfile "\t$variant\t$chr\t$centimorgans\t$pos\t$ref\t$alt\n";
      print EASsnpfile "\t$variant\t$chr\t$centimorgans\t$pos\t$ref\t$alt\n";
      print SASsnpfile "\t$variant\t$chr\t$centimorgans\t$pos\t$ref\t$alt\n";
      for(my $i=0;$i<9;++$i) { shift @fields }
      my $numIndivs=@fields;
      for(my $i=0 ; $i<$numIndivs ; ++$i) {
	my $indiv=$header[$i];
	my $genotype=$fields[$i];
	$genotype=~/(\d)\|(\d)/ || die $genotype;
	$genotype="$1$2";
	my $ethnicity=$ethnicity{$indiv}; die unless defined($ethnicity);
	if($ethnicity eq "EUR") { print EURgenofile $genotype }
	if($ethnicity eq "AMR") { print AMRgenofile $genotype }
	if($ethnicity eq "AFR") { print AFRgenofile $genotype }
	if($ethnicity eq "EAS") { print EASgenofile $genotype }
	if($ethnicity eq "SAS") { print SASgenofile $genotype }
      }
      print EURgenofile "\n"; print AFRgenofile "\n"; print AMRgenofile "\n";
      print EASgenofile "\n"; print SASgenofile "\n";
    }
  }
  close(VCF);
  close(EURsnpfile); close(EURgenofile);
  close(AMRsnpfile); close(AMRgenofile);
  close(EASsnpfile); close(EASgenofile);
  close(SASsnpfile); close(SASgenofile);
  close(AFRsnpfile); close(AFRgenofile);
  undef $interpolated;
}


sub loadGeneticPos {
  my ($chr)=@_;
  my $interpolated;
  my $file="$INTERPOLATED/chr$chr.interpolated";
  print "\tloading $file\n";
  open(IN,$file) || die $file;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=3;
    my ($pos,$centimorgans,$id)=@fields;
    $centimorgans=int($centimorgans*$PRECISION+5/9)/$PRECISION;
    $interpolated->{$pos}=$centimorgans;
  }
  close(IN);
  return $interpolated;
}



