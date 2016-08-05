#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <randomize:0/1>\n" unless @ARGV==1;
my ($RANDOMIZE)=@ARGV;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $RNA="$ASSEMBLY/rna-table.txt";
my $TRANSCRIPT_FILE="$COMBINED/HG00096/mapped.gff";
my %FATES;
$FATES{"no-transcript"}=1;
$FATES{"NMD"}=0;

my $rna=loadRNAtable($RNA);

my @allTranscripts;
if($RANDOMIZE) { loadTranscripts() }

my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $ice1="$COMBINED/$indiv/1-inactivated.txt";
  my $ice2="$COMBINED/$indiv/2-inactivated.txt";
  my $missing=getHomozygotes($ice1,$ice2);
  foreach my $rec (@$missing) {
    my $gene=$rec->{gene}; my $transcript=$rec->{transcript};
    my $fate=$rec->{fate}; my $why=$rec->{why};
    next unless $FATES{$fate};
    my $verdict="OK";
    if($RANDOMIZE) { $transcript=$allTranscripts[int(rand(@allTranscripts))] }
    if($rna->{$indiv}->{$transcript}) { $verdict="BAD" }
    print "$verdict\t$indiv\t$transcript\t$why\n";
  }
}

sub getHomozygotes
{
  my ($file1,$file2)=@_;
  my $missing1=getMissing($file1);
  my $missing2=getMissing($file2);
  my $hash=hashTranscripts($missing2);
  my $results=[];
  foreach my $rec (@$missing1) {
    next unless $hash->{$rec->{transcript}};
    push @$results,$rec;
  }
  return $results;
}



sub hashTranscripts
{
  my ($records)=@_;
  my $hash={};
  foreach my $rec (@$records) {
    $hash->{$rec->{transcript}}=1;
  }
  return $hash;
}


sub getMissing
{
  my ($file)=@_;
  my $missing=[];
  open(IN,$file) || die $file;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$fate,$why)=@fields;
    my $rec={gene=>$gene, transcript=>$transcript, fate=>$fate, why=>$why};
    push @$missing,$rec;
  }
  close(IN);
  return $missing;
}



sub loadRNAtable
{
  my ($file)=@_;
  my $table={};
  open(IN,$file) || die $file;
  my @header;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=3;
    if($fields[0] eq "transcript") { # header line
      @header=@fields;
    }
    else {
      my $numFields=@fields;
      my $transcript=$fields[0];
      for(my $i=2 ; $i<$numFields ; ++$i) {
	my $indiv=$header[$i];
	if($fields[$i]==1) { $table->{$indiv}->{$transcript}=1 }
      }
    }
  }
  close(IN);
  return $table;
}



sub loadTranscripts
{
  open(IN,$TRANSCRIPT_FILE) || die;
  my %hash;
  while(<IN>) {
    if(/transcript_id=([^;]+);/) { $hash{$1}=1 }
  }
  close(IN);
  @allTranscripts=keys %hash;
}


