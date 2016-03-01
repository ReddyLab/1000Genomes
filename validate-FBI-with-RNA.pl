#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $RNA="$ASSEMBLY/rna-table.txt";

my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $fbi1="$COMBINED/$indiv/1-inactivated.txt";
  my $fbi2="$COMBINED/$indiv/2-inactivated.txt";
  my $missing=getHomozygotes($fbi1,$fbi2);


}

sub getHomozygotes
{
  my ($file1,$file2)=@_;
  my $missing1=getMissing($file1);
  my $missing2=getMissing($file2);


}


sub getMissing
{
  my ($file)=@_;
  my $missing=[];
  open(IN,$file) || die $file;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$fate,$why)=@fields;
    my $rec={gene=>$gene; transcript=>$transcript; fate=>$fate; why=>$why};
    push @$missing,$rec;
  }
  close(IN);
  return $missing;
}




