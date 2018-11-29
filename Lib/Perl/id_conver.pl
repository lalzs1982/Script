#!/usr/bin/perl
#this code will convert ID on defined column of file2 based on file1 relationship (two columns: from col1 to col2)

my %conv;
open FI,$ARGV[0] || die "sorry$!\n"; #id relationship table
while(<FI>)
{
chomp;
my @x=split/\t/;
next if scalar(@x)<2;
$conv{$x[0]}=$x[1];
}
close FI;

my $col=$ARGV[2]; #which column 

open FI,$ARGV[1] || die "sorry$!\n"; #file with IDs to convert
while(<FI>)
{
chomp;
my @x=split/\t/;
my @ids;
map {
my $id=defined $conv{$_}?$conv{$_}:$_;
push(@ids,$id);
} (split/;/,@x[$col]);
my $ids=join(";",@ids);
print join("\t",@x[0..($col-1)],$ids,@x[($col+1)..$#x]),"\n";
}
close FI;


