#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/get-uORF-slurms";
my $SRC="$THOUSAND/src";
my $PROGRAM="$SRC/get-uORFs.pl";
my $U_BEGIN_FILE="$ASSEMBLY/uORF-begin.txt";
my $D_BEGIN_FILE="$ASSEMBLY/dORF-begin.txt";
my $U_END_FILE="$ASSEMBLY/uORF-end.txt";
my $D_END_FILE="$ASSEMBLY/dORF-end.txt";
my $DIST_FILE="$ASSEMBLY/uORF-vs-dORF-end.txt";
my $U_LENGTH_FILE="$ASSEMBLY/uORF-lengths.txt";
my $D_LENGTH_FILE="$ASSEMBLY/dORF-lengths.txt";

my (%seen,$nonoverlapping,$partiallyOverlapping,$fullyOverlapping);

open(ULENGTH,">$U_LENGTH_FILE") || die $U_LENGTH_FILE;
open(DLENGTH,">$D_LENGTH_FILE") || die $D_LENGTH_FILE;
open(UBEGIN,">$U_BEGIN_FILE") || die $U_BEGIN_FILE;
open(UEND,">$U_END_FILE") || die $U_END_FILE;
open(DBEGIN,">$D_BEGIN_FILE") || die $D_BEGIN_FILE;
open(DEND,">$D_END_FILE") || die $D_END_FILE;
open(DIST,">$DIST_FILE") || die $DIST_FILE;
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  process("$dir/1.uORFs");
  process("$dir/2.uORFs");
}
close(UBEGIN); close(UEND); close(DBEGIN); close(DEND); close(DIST);
close(ULENGTH); close(DLENGTH);

my $total=$nonoverlapping+$partiallyOverlapping+$fullyOverlapping;
my $nonPercent=$nonoverlapping/$total;
my $partialPercent=$partiallyOverlapping/$total;
my $fullPercent=$fullyOverlapping/$total;
print "nonoverlapping: $nonoverlapping / $total = $nonPercent\n";
print "partially overlapping: $partiallyOverlapping / $total = $partialPercent\n";
print "fully overlapping: $fullyOverlapping / $total = $fullPercent\n";

#===================================================================
sub process {
  my ($infile)=@_;
  open(IN,$infile) || die "cant' open file $infile";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=10;
    my ($indiv,$hap,$gene,$transcript,$uORFbegin,$uORFend,
	$dORFbegin,$dORFend,$L,$status,$reason)=@fields;
    next if $seen{$gene};
    $seen{$gene}=1;
    my $uEndDist=$L-$uORFend;
    my $dEndDist=$L-$dORFend;
    my $dist=$uORFend-$dORFend;
    next if $dist==0;
    my $uLen=$uORFend-$uORFbegin;
    my $dLen=$dORFend-$dORFbegin;
    print ULENGTH "$uLen\n";
    print DLENGTH "$dLen\n";
    print DIST "$dist\n";
    print UBEGIN "$uORFbegin\n";
    print DBEGIN "$dORFbegin\n";
    print UEND "$uEndDist\n";
    print DEND "$dEndDist\n";
    if($uORFend==$dORFend) { ++$fullyOverlapping }
    elsif($uORFend>$dORFbegin) { ++$partiallyOverlapping }
    else { ++$nonoverlapping }
  }
  close(IN);
}
#===================================================================
#===================================================================
#===================================================================
#===================================================================
#===================================================================




