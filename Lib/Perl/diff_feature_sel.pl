#!/usr/bin/perl
use strict;
use warnings;
my @colnames;
my %rec;
open FI,$ARGV[0];
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    if($.==1){@colnames=@x;next};
    
    my $i=6;
    map {
        if($_=~/[A-Z]/i)
        {
            my @yy=split/;/,$_;
            for my $yy(@yy)
            {
                if(defined $rec{$colnames[$i]}{$x[5]}{$yy}){$rec{$colnames[$i]}{$x[5]}{$yy}++}else{$rec{$colnames[$i]}{$x[5]}{$yy}=1}
            }
        
        $i++;
        }
        }  @x[$i..$#x];
}

close FI;

open FI,$ARGV[0];
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    if($.==1){@colnames=@x;next};

}