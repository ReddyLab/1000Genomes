#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;

my $name=ProgramName::get();
die "$name </path/to/individual>\n" unless @ARGV==1;
my ($path)=@ARGV;

#my $BLIND_TAB="$path/RNA/blind/tab.txt";
my $BLIND_GFF="$path/RNA/blind/stringtie-blind.gff";
#my $TAB="$path/RNA/tab.txt";
my $GFF="$path/RNA/stringtie.gff";

# Load $TAB
#my %ALT;
#open(IN,$TAB) || die "can't open $TAB\n";
#<IN>; # header
#while(<IN>) {
#  chomp; my @fields=split; next unless @fields>=7;
#  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
#  if($transcript=~/ALT/) { $ALT{$transcript}->{fpkm}=$FPKM }
#}
#close(IN);

# Load $BLIND_GFF
my %blind;
my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($BLIND_GFF);
my $n=@$transcripts;
#print "n=$n\n";
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $refID=getRefID($transcript);
  #print "refID=$refID\.\n";
  next if $refID=~/\S/;
  my $key=hash($transcript);
  #print "blind key: [$key]\n";
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
  my $key=hash($transcript);
  #print "alt key: [$key]\n";
  my $found=0+$blind{$key};
  print "$refID\t$found\n";
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


