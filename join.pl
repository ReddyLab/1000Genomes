#!/usr/bin/perl
use strict;

my $BASE="/home/bmajoros/hapmix";

my @pos;
open(IN,"$BASE/data-prep/ref/AMRsnpfile.10") || die;
while(<IN>) {
    chomp; my @fields=split; next unless @fields>=6;
    my ($rs,$chr,$centimorgans,$pos,$ref,$alt)=@fields;
    push @pos,$pos;
}
close(IN);

my @files=`ls $BASE/output`;
foreach my $file (@files) {
    chomp $file;
    next unless($file=~/AMR.LOCALANC.*.10/);
    my $outfile="$BASE/joined/$file";
    open(OUT,">$outfile") || die $outfile;
    open(IN,"$BASE/output/$file") || die $file;
    my $i=0;
    while(<IN>) {
	chomp; my @fields=split; next unless @fields>=3;
	my $pos=$pos[$i++];
	my $expect=1*$fields[1]+2*$fields[2];
	print OUT "$pos\t$expect\n";
    }
    close(IN);
    close(OUT);
}

