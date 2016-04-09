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
  my (@points,$n0,$n1,$n2,$expressed);
  for(my $i=0 ; $i<$n ;++$i) {
    my $rec=$array[$i];
    my $functionalCopies=0;
    if($rec->{status}->[0] eq "functional") { ++$functionalCopies }
    if($rec->{status}->[1] eq "functional") { ++$functionalCopies }
    my $fpkm;
    foreach my $x (@{$rec->{FPKM}}) {$fpkm+=$x}
    #if($fpkm>0) { $expressed=1 }
    if($fpkm>=5) { $expressed=1 }
    push @points,[$functionalCopies,$fpkm];
    if($functionalCopies==0) { ++$n0 }
    elsif($functionalCopies==1) { ++$n1 }
    elsif($functionalCopies==2) { ++$n2 }
  }
  next unless $expressed;
  #next unless $n0+$n1>=5 && $n2>=5;
  next unless $n0>=5 && $n1>=5 && $n2>=5;
  my $mean=meanFPKM(\@points);
  next unless $mean>0;
  foreach my $point (@points) {
    my ($copies,$fpkm)=@$point;
    my $score=log($fpkm/$mean+1);
    print "$chr\t$transcriptID\t$copies\t$score\n";
  }
}



sub meanFPKM
{
  my ($array)=@_;
  my $n=@$array;
  my $sum=0;
  for(my $i=0 ; $i<$n ; ++$i) {
    next unless $array->[$i]->[0]==2;
    $sum+=$array->[$i]->[1];
  }
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

