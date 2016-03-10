#!/usr/bin/perl
use strict;
use SummaryStats;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my %hash;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $infile="$dir/nmd.txt";
  next if -z $infile;
  process($infile);
}
my @transcriptIDs=keys %hash;
my $n=@transcriptIDs;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcriptID=$transcriptIDs[$i];
  my $array=$hash{$transcriptID};
  my $n=@$array;
  my (@nmd,@functional);
  for(my $i=0 ; $i<$n ;++$i) {
    my $rec=$array->[$i];
    if($rec->{status} eq "functional") { push @functional,$rec }
    else { push @nmd,$rec }
  }
  next unless @nmd>0;
  my (@nmdFPKM,@functionalFPKM);
  addFPKMs(\@nmd,\@nmdFPKM);
  addFPKMs(\@functional,\@functionalFPKM);

  my ($meanNMD,$sdNMD,$minNMD,$maxNMD)=SummaryStats::summaryStats(\@nmdFPKM);
  my ($meanFunc,$sdFunc,$minFunc,$maxFunc)=
    SummaryStats::summaryStats(\@functionalFPKM);
  print "$transcriptID\t$meanNMD\t$meanFunc\t$sdNMD\t$sdFunc\n";
}



sub addFPKMs
{
  my ($from,$to)=@_;
  my $n=@$from;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $rec=$from->[$i];
    push @$to,$rec->{FPKM};
  }
}



sub process
{
  my ($infile)=@_;
  open(IN,$infile) || die "can't open $infile\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($transcript,$indiv,$status,$fpkm)=@fields;
    my $rec={indiv=>$indiv,status=>$status,FPKM=>$fpkm};
    push @{$hash{$transcript}},$rec;
  }
  close(IN);
}

