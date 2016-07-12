#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <largest-job-num> <outputs-directory>\n" unless @ARGV==2;
my ($N,$dir)=@ARGV;

my @done;
for(my $i=1 ; $i<=$N ; ++$i) { $done[$i]=0 }
my @files=`ls $dir`;
foreach my $file (@files) {
  chomp $file;
  next unless $file=~/(\d+)\.output/;
  my $index=$1;
  if(done($file)) { $done[$index]=1 }
}
my $n=@done;
my $first=1;
for(my $i=1 ; $i<$n ; ++$i) {
  next if $done[$i];
  my $j; for($j=$i+1 ; $j<$n && !$done[$j]; ++$j) {}
  if(!$first) { print "," }
  my $end=$j-1;
  if($i==$end) { print "$i" }
  else { print "$i\-$end" }
  $i=$j;
  $first=0;
}
print "\n";


sub done
{
  my ($filename)=@_;
  open(IN,"tail $filename|") || die $filename;
  while(<IN>) {
    if(/\[done\]/) { close(IN); return 1 }
  }
  close(IN);
  return 0;
}



