#!/usr/bin/perl
use strict;

my $SLURMS="/home/bmajoros/1000G/assembly/RNA-sim-slurms";

my %running;
my @list=`squeue -u bmajoros`;
foreach my $line (@list) {
  chomp $line;
  next unless($line=~/SIM(\d+)/);
  $running{$1}=1;
}

my @slurms=`ls $SLURMS/*.slurm`;
foreach my $slurm (@slurms) {
  chomp $slurm;
  my ($jobID,$dir);
  open(IN,$slurm) || die $slurm;
  while(<IN>) {
    if(/SIM(\d+)/) { $jobID=$1 }
    elsif(/(\S+)stringtie.gff/) { $dir=$1 }
  }
  close(IN);
  if(!$running{$jobID}) {
    if(!-e "$dir/stringtie.gff" ||
       -e "$dir/accepted_hits.bam") {
      print "sbatch $jobID.slurm\n";
    }
  }
  if($running{$jobID}) { print "$jobID : running\n" }
  else {
#    if(-e "$dir/stringtie.gff") { print "$jobID : stringtie.gff exists\n" }
#    if(!-e "$dir/accepted_hits.bam") { print "$jobID : bam was deleted\n" }
    if(-e "$dir/stringtie.gff" && !-e "$dir/accepted_hits.bam")
      { print "$jobID : finished\n" }
  }
}

