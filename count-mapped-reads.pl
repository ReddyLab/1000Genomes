#!/usr/bin/perl -w
use strict;
use warnings;

my $VERBOSE=0;

my (%counts,$kept,$discarded,$total);
$kept=0; $discarded=0; $total=0;
while(<STDIN>) {
  next if(/^\@/);
  chomp;
  my @fields=split/\t/,$_;
  next unless @fields>=11;
  my($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq,
     $qual) = @fields;

  # 0x1: aligned with multiple segments
  # 0x2: each segment properly aligned
  # 0x4 segment unmapped
  # 0x8 next segment in the template unmapped
  # 0x10 SEQ being reverse complemented
  # 0x20 SEQ of the next segment in the template being reverse complemented
  # 0x40 the first segment in the template
  # 0x80 the last segment in the template
  # 0x100 secondary alignment
  # 0x200 not passing filters, such as platform/vendor quality controls
  # 0x400 PCR or optical duplicate
  # 0x800 supplementary alignment

  #printFlags($flag);
  #allFlags($qname,$flag);

  if(#$flag & 0x1 && # aligned with multiple segments
     #$flag & 0x2 && # both ends aligned
     #$flag & 0x40 && # count only the first segment
     #!($flag & 0x4 && $flag & 0x8) && # neither end is unmapped
     !($flag & 0x4) && # this read is mapped
     !($flag & 0x100) && # not a secondary alignment
     !($flag & 0x400) && # not a PCR or optical duplicate
     !($flag & 0x800)) # not a supplementary alignment
    { ++$kept; ++$counts{$rname} }
  else {
    if($VERBOSE) {
      print "discarded #$total\n";
      #if(!($flag & 0x1)) { print "\tFAILED: no 0x1 flag (multiple segs)\n" }
      #if(!($flag & 0x2)) { print "\tFAILED: no 0x2 flag (all segs mapped)\n" }
      #if(!($flag & 0x40)) { print "\tFAILED: no 0x40 flag (not first seg)\n" }
      if($flag & 0x100) { print "\tFAILED: 0x100 secondary alignment\n" }
      #if($flag & 0x4) { print "\tFAILED: 0x4 segment unmapped\n" }
      #if($flag & 0x8) { print "\tFAILED: 0x8 next segment unmapped\n" }
      if($flag & 0x400) { print "\tFAILED: 0x400 PCR or optical duplicate\n" }
      if($flag & 0x800) { print "\tFAILED: 0x800 supplementary alignment\n" }
    }
    ++$discarded;
  }
  ++$total;
  #if($total>=100000) { print "$kept kept, $discarded discarded\n"; last }
}
my @keys=keys %counts;
my $n=@keys;
for(my $i=0 ; $i<$n ; ++$i) {
  my $key=$keys[$i];
  my $count=$counts{$key};
  print "$key\t$count\n";
}
print "TOTAL MAPPED READS: $kept\tDISCARDED: $discarded\n";

sub allFlags
{
  my ($read,$flag)=@_;
  for(my $i=0 ; $i<16 ; ++$i) {
    my $mask=1;
    for(my $j=0 ; $j<$i ; ++$j) { $mask=$mask<<$j }
    if($flag & $mask) { print "\t$read\tbit $i = $mask is set\n" }
  }
}

sub printFlags
{
  my ($flag)=@_;
  print "FLAGS: \n";
  if($flag & 0x1) { print "\t0x1 aligned with multiple segments\n" }
  if($flag & 0x2) { print "\t0x2 each segment properly aligned\n" }
  if($flag & 0x4) { print "\t0x4 segment unmapped\n" }
  if($flag & 0x8) { print "\t0x8 next segment in the template unmapped\n" }
  if($flag & 0x10) { print "\t0x10 SEQ being reverse complemented\n" }
  if($flag & 0x20) { print "\t0x10 SEQ of the next segment in the template being reverse complemented\n" }
  if($flag & 0x40) { print "\t0x40 the first segment in the template\n" }
  if($flag & 0x80) { print "\t0x80 the last segment in the template\n" }
  if($flag & 0x100) { print "\t0x100 secondary alignment\n" }
  if($flag & 0x200) { print "\t0x200 not passing filters, such as platform/vendor quality controls\n" }
  if($flag & 0x400) { print "\t0x40 PCR or optical duplicate\n" }
  if($flag & 0x800) { print "\t0x800 supplementary alignment\n" }
}


