#!/usr/bin/perl
use strict;

my $url="https://swift.oit.duke.edu/v1/AUTH_biostat/ICE";
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

print "<html>\n";
print "<big><big>\n";
print "<ul>\n";
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/^HG\d+$/ || $indiv=~/^NA\d+$/;
  my $dir="$COMBINED/$indiv";
  print "<li><a href=\"$url/$indiv-1.essex.gz\">$indiv-1.essex.gz</a>\n";
  print "<li><a href=\"$url/$indiv-2.essex.gz\">$indiv-2.essex.gz</a>\n";
}

print "</ul>\n";
print "</big></big>\n";
print "</html>\n";


