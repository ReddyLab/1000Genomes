#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/specific-questions-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
#  $writer->addCommand("$THOUSAND/src/specific-questions.pl $dir/1.essex > $dir/1.specific-questions");
#  $writer->addCommand("$THOUSAND/src/specific-questions.pl $dir/2.essex > $dir/2.specific-questions");
  $writer->addCommand("$THOUSAND/src/specific-questions.pl $dir/1.essex > $dir/1.specific-questions-conservative");
  $writer->addCommand("$THOUSAND/src/specific-questions.pl $dir/2.essex > $dir/2.specific-questions-conservative");
}
#$writer->mem(5000);
$writer->setQueue("new,all");
$writer->writeArrayScript($SLURM_DIR,"QUES",$SLURM_DIR,500);



