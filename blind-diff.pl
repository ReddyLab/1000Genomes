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
print "n=$n\n";
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $refID=getRefID($transcript);
  print "refID=$refID\.\n";
  next if $refID=~/\S/;
  my $key=hash($transcript);
  print "blind key: [$key]\n";
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
  my $h="";
  my $substrate=$transcript->getSubstrate();
  my $exons=$transcript->getRawExons();
  foreach my $exon (@$exons) {
    my $begin=$exon->getBegin(); my $end=$exon->getEnd();
    $h.="$begin\-$end ";
  }
  return $h;
}


