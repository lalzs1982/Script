#!/usr/bin/perl
use strict;
use warnings;

my @lables=split/,/,$ARGV[0];
my %rec;

#print STDERR "labels are : @lables \n";
my $i=0;
for my $file(@ARGV[1..$#ARGV])
{
    open FI,$file || die "sorry$!\n";
    #print STDERR "it is reading file $file\n";
    my @x;
    while(<FI>)
    {
        chomp;
        @x=split/\t/,$_;
        my $id=join("\t",@x[0..4]);
        for my $j(5..$#x)
        {
            $rec{$id}{$lables[$i+$j-5]}=$x[$j];
        }
    }
    
    $i+=($#x-4);
    close FI;
}

print join("\t","Chr","Start","End","Ref","Alt",@lables),"\n";


for my $id(keys%rec)
{
    my @out;
    map {if(defined $rec{$id}{$_}){push(@out,$rec{$id}{$_})}else{push(@out,'-')}} @lables;
    print join("\t",$id,@out),"\n";
}

