#!/usr/bin/perl
use strict;
$|=1;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my @subdirs=`ls $COMBINED`;
my $confirmed=0;
foreach my $subdir (@subdirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+/ || $subdir=~/^NA\d+/;
  compare("$COMBINED/$subdir/1.essex","$COMBINED/$subdir/1.essex.old",$subdir);
  compare("$COMBINED/$subdir/2.essex","$COMBINED/$subdir/2.essex.old",$subdir);
}
print "$confirmed confirmed\n";

sub compare
{
  my ($file1,$file2,$subdir)=@_;
  my $size1=getSize($file1);
  my $size2=getSize($file2);
  if($size1==$size2) { ++$confirmed }
  #if($size1==$size2) { print "\t\t\t$subdir -- OK!\n" }
  else { print "$subdir: $size1 vs $size2\n" }
  
}

sub getSize
{
  my ($file)=@_;
  my $line=`ls -la $file`;
  chomp $line;
  my @fields=split/\s+/,$line;
  my $size=$fields[4];
  return $size;
}





