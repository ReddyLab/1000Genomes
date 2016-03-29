#!/usr/bin/perl
use strict;
use SummaryStats;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined-hg19";

my %chr;
open(IN,"$ASSEMBLY/local-CDS-and-UTR.gff") || die;
while(<IN>) {
  if(/^(chr\S+)\s.*transcript_id=([^;]+);/) { $chr{$2}=$1 }
}
close(IN);

my (%hash,%byIndiv,%indivNMD,%indivHomoNMD);
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $infile="$dir/nmd.txt";
  next if -z $infile;
  process($infile);
}
my @indivs=keys %byIndiv;
foreach my $indiv (@indivs) {
  my $hash=$byIndiv{$indiv};
  my @array=values(%$hash);
  my $n=@array;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $rec=$array[$i];
    my $functionalCopies=0;
    if($rec->{status}->[0] eq "functional") { ++$functionalCopies }
    if($rec->{status}->[1] eq "functional") { ++$functionalCopies }
    if($functionalCopies<2) { ++$indivNMD{$indiv} }
    if($functionalCopies==0) { ++$indivHomoNMD{$indiv} }
  }
}
my @array=values %indivNMD;
my ($mean,$stddev,$min,$max)=SummaryStats::summaryStats(\@array);
print "# transcripts NMD per individual:\t$mean +/- $stddev ($min\-$max)\n";
my @array=values %indivHomoNMD;
my ($mean,$stddev,$min,$max)=SummaryStats::summaryStats(\@array);
print "# transcripts homozygous NMD per individual:\t$mean +/- $stddev ($min\-$max)\n";
my @transcriptIDs=keys %hash;
my $n=@transcriptIDs;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcriptID=$transcriptIDs[$i];
  my $chr=$chr{$transcriptID};
  next if $chr eq "chrX" || $chr eq "chrY";
  my @array=values(%{$hash{$transcriptID}});
  my $n=@array;
  my (@functional0,@functional1,@functional2);
  for(my $i=0 ; $i<$n ;++$i) {
    my $rec=$array[$i];
    my $functionalCopies=0;
    if($rec->{status}->[0] eq "functional") { ++$functionalCopies }
    if($rec->{status}->[1] eq "functional") { ++$functionalCopies }
    #if($rec->{status}->[0] ne "mapped-NMD") { ++$functionalCopies }
    #if($rec->{status}->[1] ne "mapped-NMD") { ++$functionalCopies }
    if($functionalCopies==2) { push @functional2,$rec }
    elsif($functionalCopies==1) { push @functional1,$rec }
    elsif($functionalCopies==0) { push @functional0,$rec }
  }
  my $n0=@functional0+0; my $n1=@functional1+0; my $n2=@functional2+0;
  #print "XXX $n0\t$n1\t$n2\n";
  next unless $n0+$n1>=1 && $n2>=1;
  my (@FPKM0,@FPKM1,@FPKM2);
  addFPKMs(\@functional0,\@FPKM0);
  addFPKMs(\@functional1,\@FPKM1);
  addFPKMs(\@functional2,\@FPKM2);

  my $n0=@FPKM0; my $n1=@FPKM1; my $n2=@FPKM2;
  my $mean0=mean(\@FPKM0);
  my $mean1=mean(\@FPKM1);
  my $mean2=mean(\@FPKM2);
  next unless $mean2>0;
  print "$chr\t$transcriptID\t$mean0\t$mean1\t$mean2\t$n0\t$n1\t$n2\n";
}



sub mean
{
  my ($array)=@_;
  my $n=@$array;
  my $sum=0;
  for(my $i=0 ; $i<$n ; ++$i) { $sum+=$array->[$i] }
  return $n>0 ? $sum/$n : 0;
}


sub addFPKMs
{
  my ($from,$to)=@_;
  my $n=@$from;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $rec=$from->[$i];
    push @$to,$rec->{FPKM}->[0]+$rec->{FPKM}->[1];
  }
}



sub process
{
  my ($infile)=@_;
  open(IN,$infile) || die "can't open $infile\n";
  while(<IN>) {
    chomp; my @fields=split/\t/; next unless @fields>=4;
    my ($transcript,$indiv,$status,$fpkm)=@fields;
    my $rec=$hash{$transcript}->{$indiv};
    if(!$rec) {
      $byIndiv{$indiv}->{$transcript}=
	$hash{$transcript}->{$indiv}=
	  $rec={status=>[],FPKM=>[]} }
    push @{$rec->{status}},$status;
    push @{$rec->{FPKM}},$fpkm;
  }
  close(IN);
}

