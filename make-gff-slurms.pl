#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/gff-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
#  $writer->addCommand("/home/bmajoros/ICE/essex-to-gff-AS.pl $dir/1.essex $dir/1.gff 1");
#  $writer->addCommand("/home/bmajoros/ICE/essex-to-gff-AS.pl $dir/2.essex $dir/2.gff 2");
  $writer->addCommand("/home/bmajoros/ICE/essex-to-gff-AS.pl $dir/1.essex $dir/1.gff 1");
  $writer->addCommand("/home/bmajoros/ICE/essex-to-gff-AS.pl $dir/2.essex $dir/2.gff 2");
}
#$writer->mem(5000);
$writer->setQueue("new,all");
$writer->nice(500);
$writer->writeArrayScript($SLURM_DIR,"GFF",$SLURM_DIR,1000);


