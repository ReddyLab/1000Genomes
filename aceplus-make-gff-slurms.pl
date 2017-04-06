#!/usr/bin/perl
use strict;
use SlurmWriter;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $SLURM_DIR="$ASSEMBLY/aceplus-gff-slurms";

my $writer=new SlurmWriter();
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/1.aceplus.full";
  $writer->addCommand("/home/bmajoros/ACEPLUS/essex-to-gff-AS2.pl $dir/1.aceplus.full $dir/1.aceplus.gff 1");
  $writer->addCommand("/home/bmajoros/ACEPLUS/essex-to-gff-AS2.pl $dir/2.aceplus.full $dir/2.aceplus.gff 2");
}
#$writer->mem(5000);
$writer->setQueue("new,all");
$writer->nice(500);
$writer->writeArrayScript($SLURM_DIR,"GFF",$SLURM_DIR,1000);


