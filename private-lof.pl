#!/usr/bin/perl
use strict;
use ProgramName;

my $ETHNIC="inactivation-analysis-het2.txt";
my $POP_FILE="populations.txt";

my %pop;
open(IN,$POP_FILE) || die $POP_FILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($indiv,$pop)=@fields;
  $pop{$indiv}=$pop;
}
close(IN);

my (%ethnicGenes,%ethnicTranscripts);
open(IN,$ETHNIC) || die $ETHNIC;
while(<IN>) {
  chomp; my @fields=split;
  next unless @fields>=4 && $fields[3]=~/P=(\S+)/;
  my ($pop,$transcript,$gene)=@fields;
  $ethnicGenes{$pop}->{$gene}=1;
  $ethnicTranscripts{$pop}->{$transcript}=1;
}
close(IN);

print "indiv\tshared\tprivate\n";
my @dirs=`ls combined`;
foreach my $dir (@dirs) {
  chomp $dir;
  next unless $dir=~/^HG/ || $dir=~/^NA/;
  process("combined/$dir/1-inactivated.txt",$dir);
  process("combined/$dir/2-inactivated.txt",$dir);
}

sub process
{
  my ($filename,$indiv)=@_;
  my $private=0; my $shared=0;
  my $pop=$pop{$indiv};
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$fate,$why)=@fields;
    if($ethnicTranscripts->{$pop}->{$transcript}) { ++$shared }
    else { ++$private }
  }
  close(IN);
  print "$indiv\t$shared\t$private\n";
}






