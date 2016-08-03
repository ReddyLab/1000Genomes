#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;

my $STRUCTURE_CHANGES="/home/bmajoros/1000G/assembly/structure-changes.txt";

my $name=ProgramName::get();
die "$name </path/to/individual> <cryptic-site|exon-skipping>\n"
  unless @ARGV==2;
my ($path,$CHANGE)=@ARGV;

my $BLIND_GFF="$path/RNA/blind/stringtie-blind.gff";
my $GFF="$path/RNA/stringtie.gff";
my $INPUT_GFF1="$path/1.gff";
my $INPUT_GFF2="$path/2.gff";

# Load list of structure changes
my %changes;
open(IN,$STRUCTURE_CHANGES) || die $STRUCTURE_CHANGES;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=3;
  my ($indiv,$hap,$gene,$transcript,$change)=@fields;
  $changes{$transcript}=$change;
}
close(IN);

# Count how many ALT transcripts were provided to StringTie
my $reader=new GffTranscriptReader();
my $total=countALT($reader,$INPUT_GFF1)+countALT($reader,$INPUT_GFF2);
print "TOTAL=$total\n";
#exit;

# Load $BLIND_GFF
my %blind;
my $transcripts=$reader->loadGFF($BLIND_GFF);
my $n=@$transcripts;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $refID=getRefID($transcript);
  next if $refID=~/\S/;
  my $key=hash($transcript);
  $blind{$key}=1;
}

# Load $GFF
my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($GFF);
my $n=@$transcripts;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $refID=getRefID($transcript);
  next unless $refID=~/ALT/;
  next unless $changes{$refID} eq $CHANGE;
  my $key=hash($transcript);
  my $found=0+$blind{$key};
  my $gene=$transcript->getSubstrate();
  print "$gene\t$refID\t$found\n";
}

print STDERR "[done]\n";

sub getRefID {
  my ($transcript)=@_;
  my $extra=$transcript->parseExtraFields();
  my $hash=$transcript->hashExtraFields($extra);
  my $refID=$hash->{"reference_id"};
  return $refID;
}

sub hash {
  my ($transcript)=@_;
  my $substrate=$transcript->getSubstrate();
  my $h="$substrate ";
  my $exons=$transcript->getRawExons();
  my $strand=$transcript->getStrand();
  my $n=@$exons;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $exon=$exons->[$i];
    my $begin=$exon->getBegin(); my $end=$exon->getEnd();
    if($i==0) {
      if($strand eq "+") { $h.="$end " }
      else { $h.="$begin " }
    }
    elsif($i==$n-1) {
      if($strand eq "+") { $h.="$begin " }
      else { $h.="$end " }
    }
    else { $h.="$begin\-$end " }
  }
  return $h;
}


sub countALT {
  my ($reader,$infile)=@_;
  my $transcripts=$reader->loadGFF($infile);
  my $n=@$transcripts;
  my $count=0;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $transcript=$transcripts->[$i];
    my $refID=$transcript->getTranscriptId();
    next unless $changes{$refID} eq $CHANGE;
    if($refID=~/ALT/) { ++$count }
  }
  return $count;
}
