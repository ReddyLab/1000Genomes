#!/usr/bin/perl
use strict;
use ProgramName;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my $name=ProgramName::get();
die "$name <path-to-individual>\n" unless @ARGV==1;
my ($subdir)=@ARGV;
my ($totalWarnings,$totalErrors);

my $dir="$COMBINED/$subdir";
process("$dir/1.fasta");
process("$dir/2.fasta");
print "$totalWarnings\t$totalErrors\n";

sub process {
  my ($infile)=@_;
  open(IN,$infile) || die "Can't open $infile\n";
  while(<IN>) {
    chomp;
    next unless(/^\s*>.*\/warnings=(\d+)\s+\/errors=(\d+)/);
    my ($warnings,$errors)=($1,$2);
    $totalWarnings+=$warnings;
    $totalErrors+=$errors;
  }
  close(IN);
}






