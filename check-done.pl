#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <slurm-directory>\n" unless @ARGV==1;
my ($slurmDir)=@ARGV;

my $dir="$slurmDir/outputs";
die "$dir does not exist\n" unless -e $dir;
my @commands=`ls $slurmDir/command*.sh`;
my $N=@commands;

my @done;
for(my $i=1 ; $i<=$N ; ++$i) { $done[$i]=0 }
for(my $i=1 ; $i<=$N ; ++$i) {
  my $file="$dir/$i.output";
  if(-e $file && done($file)) { $done[$i]=1 }
}
my $first=1;
my $ok=1;
for(my $i=1 ; $i<=$N ; ++$i) {
  next if $done[$i];
  $ok=0;
  my $j; for($j=$i+1 ; $j<=$N && !$done[$j]; ++$j) {}
  if(!$first) { print "," }
  my $end=$j-1;
  if($i==$end) { print "$i" }
  else { print "$i\-$end" }
  $i=$j;
  $first=0;
}
if($ok) { print "all jobs finished successfully" }
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



