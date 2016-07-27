#!/usr/bin/perl
use strict;




sub parseTophat {
  my ($filename)=@_;
  my $introns=[];
  open(IN,$filename) || die "Can't open $filename";
  <IN>; # header
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=10;
    my ($gene,$begin,$end,$junc,$reads,$strand,$b,$e,$color,$two,$overhangs)=
      @fields;
    $overhangs=~/(\d+),(\d+)/ || die $overhangs;
    my $donor=$begin+$1; my $acceptor=$end-$2;
    my $record=
      {
       gene=>$gene,
       donor=>$donor,
       acceptor=>$acceptor
      };
  }
  close(IN);
}





