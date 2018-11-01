#!/usr/bin/perl
use strict;
use warnings;
my $multifile=$ARGV[0];
my %outcols;
map {$outcols{$_}=1} @ARGV[1..$#ARGV];

my %rec;
my @colnames;
open(FI,$ARGV[0]) || die "sorry,$!\n";
while (<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    
    if ($.==1)
    {
        @colnames=@x;
        #print join("\t",@x),"\n"; 
	#next
    };
    my @out;
    map {if (defined $outcols{$colnames[$_]}){push(@out,$x[$_])}} 0..$#colnames;
    
	print join("\t",@out),"\n";
}
close FI;

