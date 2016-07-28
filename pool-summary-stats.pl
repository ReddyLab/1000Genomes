#!/usr/bin/perl
use strict;
use SummaryStats;
$|=1;

# Some globals
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

# Process input files
my @indivs=`ls $COMBINED`;
foreach my $indiv (@indivs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  process("$COMBINED/$indiv/1.summary-stats");
  process("$COMBINED/$indiv/2.summary-stats");
}

my (@errors,@bad,@NMD,@PTC,@ATG,@splicing,@frameshift,@valid,@donor,
    @acceptor,@protein,@newStart,@newStartNMD);
sub process
{
  my ($infile)=@_;
  open(IN,$infile) || die "can't open $infile";
  while(<IN>) {
    next if(/EJC_DISTANCE/); next if(/done/);
    if(/(\d+) genes had too many VCF errors/) { push @errors,$1 }
    if(/(\d+) genes had bad annotations/) { push @bad,$1 }
    if(/(\d+) mapped genes had NMD/) { push @NMD,$1 }
    if(/(\d+) mapped genes had a premature stop/) { push @PTC,$1 }
    if(/(\d+) mapped genes had a change to the start codon/) { push @ATG,$1 }
    if(/(\d+) genes had splicing changes/) { push @splicing,$1 }
    if(/(\d+) mapped genes had a frameshift indel/) { push @frameshift,$1 }
    if(/(\d+) genes had a valid annotation/) { push @valid,$1 }
    if(/(\d+) genes had at broken donor site/) { push @donor,$1 }
    if(/(\d+) genes had a broken acceptor site/) { push @acceptor,$1 }
    if(/(\d+) genes had a mapped transcript whose protein changed/)
      { push @protein,$1 }
    if(/(\d+) genes had a new upstream start codon/) { push @newStart,$1 }
    if(/(\d+) genes had a new upstream start codon predicted to cause NMD/)
      { push @newStartNMD,$1 }
  }
  close(IN);
}
report(\@errors,"genes with too many VCF errors");
report(\@bad,"genes with bad annotations");
report(\@NMD,"mapped genes with NMD");
report(\@PTC,"mapped genes with a PTC");
report(\@ATG,"mapped genes with change to ATG");
report(\@splicing,"genes with splicing changes");
report(\@frameshift,"mapped genes w/frameshift indel");
report(\@valid,"genes with a valid annotation");
report(\@donor,"genes with a broken donor");
report(\@acceptor,"genes with a broken acceptor");
report(\@protein,"mapped transcripts whose proteins changed");
report(\@newStart," genes with new upstream start codon");
report(\@newStartNMD," genes with new upstream start codon causing NMD");

sub report
{
  my ($array,$label)=@_;
  my ($mean,$stddev,$min,$max)=SummaryStats::roundedSummaryStats($array);
  print "$mean +- $stddev ($min\-$max) $label\n";
}





