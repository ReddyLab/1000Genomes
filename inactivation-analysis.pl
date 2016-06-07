#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <inactivation-table.txt> <randomize-fraction> <alpha>\n" 
  unless @ARGV==3;
my ($RNA,$RANDOMIZE_FRACTION,$ALPHA)=@ARGV;

$RANDOMIZE_FRACTION=0+$RANDOMIZE_FRACTION;
my $RANDOMIZE=1;
my $THOUSAND="/home/bmajoros/1000G";
my $POP="$THOUSAND/assembly/populations.txt";

# Compute adjusted alpha level to control FWER
my $m=`wc -l $RNA`-1;
$ALPHA=1-(1-$ALPHA)**(1/$m);
print "adjusted alpha=$ALPHA\n";

# Load the list of individuals actually present in our data
my %present;
open(IN,$RNA) || die $RNA;
my $line=<IN>; chomp $line; my @fields=split/\s+/,$line;
close(IN);
foreach my $ID (@fields) { $present{$ID}=1 }

# Read the ethnicity file
my (%ethnicity,%multinomial);
open(IN,$POP) || die $POP;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>=2;
  my ($ID,$pop)=@fields;
  next unless $present{$ID};
  $ethnicity{$ID}=$pop;
  ++$multinomial{$pop};
}
close(IN);
my @ethnicities=keys %multinomial;

# Randomize the ethnicity assignment, to generate a null distribution
if($RANDOMIZE) {
  my @IDs=keys %ethnicity;
  my $numIDs=@IDs;
  $numIDs=$RANDOMIZE_FRACTION*$numIDs;
  for(my $i=0 ; $i<$numIDs ; ++$i) {
    my $j=int(rand($numIDs-$i))+$i;
    my $idI=$IDs[$i]; my $idJ=$IDs[$j];
    my $ethI=$ethnicity{$idI}; my $ethJ=$ethnicity{$idJ};
    #print "swapping $i and $j <=> $ethI and $ethJ\n";
    $ethnicity{$idI}=$ethJ; $ethnicity{$idJ}=$ethI;
  }
}

# Process the RNA counts file
my @header;
open(IN,$RNA) || die $RNA;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>100;
  if($fields[0] eq "transcript") { @header=@fields; next }
  my $transcript=$fields[0];
  my $gene=$fields[1];
  my $numFields=@fields;
  my (%counts,%nonCounts);
  for(my $i=2 ; $i<$numFields ; ++$i) {
    my $ID=$header[$i];
    next unless $present{$ID};
    my $ethnic=$ethnicity{$ID}; die unless length($ethnic)>0;
    if($fields[$i]>0) { ++$counts{$ethnic} }
    else { ++$nonCounts{$ethnic} }
  }
  my $N=0;
  my $numEth=@ethnicities;
  my (@table,$tableText,$numZeros,$colSum1,$colSum2);
  foreach my $key (@ethnicities) {
    my $count=0+$counts{$key};
    my $nonCount=0+$nonCounts{$key};
    $tableText.="$key\t$count\t$nonCount\n";
    my $row=[$count,$nonCount];
    push @table,$row;
  }
  my $continue=1;
  my @tableEthnicities=@ethnicities;
  while($continue && hasNonzeroBroken(\@table))
  {
    my $mostExtremeRow=mostExtremeRow(\@table);
    my $collapsed=collapse(\@table,$mostExtremeRow);
    my $cmd="/home/bmajoros/src/scripts/fisher-exact-test.R";
    for(my $i=0 ; $i<2 ; ++$i) {
      for(my $j=0 ; $j<2 ; ++$j) {
	my $entry=$collapsed->[$i]->[$j];
	$cmd.=" $entry";
      }
    }
    my $P=0+`$cmd`;
    if($P<$ALPHA) {
      my $pop=$tableEthnicities[$mostExtremeRow];
      print "$pop\t$transcript\t$gene\tP=$P\n";
      print "pop\tpresent\tabsent\n";
      print "$tableText";
      print "================================\n";
      deleteRow(\@table,$mostExtremeRow);
      splice(@tableEthnicities,$mostExtremeRow,1);
      $tableText="";
      foreach my $key (@tableEthnicities) {
	my $count=0+$counts{$key};
	my $nonCount=0+$nonCounts{$key};
	$tableText.="$key\t$count\t$nonCount\n";
      }
    }
    else { $continue=0 }
  }
}
close(IN);



sub hasNonzeroBroken
{
  my ($table)=@_;
  my $numRows=@$table; #die unless $numRows==5;
  if($numRows<2) { return 0 }
  my $numCols=@{$table->[0]}; die unless $numCols==2;
  for(my $i=0 ; $i<$numRows ; ++$i) {
    if($table->[$i]->[1]>0) { return 1 }
  }
  return 0;
}


sub collapse
{
  # Input: array of rows, each of which is a pointer to a n array of columns

  my ($table,$mostExtreme)=@_;
  my $collapsed=[];
  my $numRows=@$table; #die unless $numRows==5;
  my $numCols=@{$table->[0]}; die unless $numCols==2;
  for(my $i=0 ; $i<$numRows ; ++$i) {
    for(my $j=0 ; $j<$numCols ; ++$j) {
      my $entry=$table->[$i]->[$j];
      my $rowId=($i==$mostExtreme ? 1 : 0);
      $collapsed->[$rowId]->[$j]+=$entry;
    }
  }
  return $collapsed;
}



sub deleteRow
{
  # Input: array of rows, each of which is a pointer to a n array of columns

  my ($table,$rowIndex)=@_;
  splice(@$table,$rowIndex,1);
}



sub mostExtremeRow
{
  # Input: array of rows, each of which is a pointer to a n array of columns

  my ($table)=@_;
  my $numRows=@$table; #die unless $numRows==5;
  my $numCols=@{$table->[0]}; die unless $numCols==2;
  my (@rowSums,@colSums);
  for(my $i=0 ; $i<$numRows ; ++$i) {
    for(my $j=0 ; $j<$numCols ; ++$j) {
      my $entry=$table->[$i]->[$j];
      $rowSums[$i]+=$entry;
      $colSums[$j]+=$entry;
    }
  }
  my ($total,@colProportions);
  for(my $j=0 ; $j<$numCols ; ++$j) { $total+=$colSums[$j] }
  for(my $j=0 ; $j<$numCols ; ++$j) { $colProportions[$j]=$colSums[$j]/$total }
  my ($biggestDeviation,$biggestIndex);
  for(my $i=0 ; $i<$numRows ; ++$i) {
    my $expectedCount=$colProportions[0]*$rowSums[$i];
    my $deviation=$expectedCount-$table->[$i]->[0];
    if($deviation>$biggestDeviation) {
      $biggestDeviation=$deviation;
      $biggestIndex=$i;
    }
  }
  return $biggestIndex;
}





