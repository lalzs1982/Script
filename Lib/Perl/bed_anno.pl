#!/usr/bin/perl
use strict;
use warnings;
#this code was used to reformate two bed overlapped file as each column represent one regions of the second bed
my %rec;
my %regs;
my $bed_cols=$ARGV[1]; #number of columns for the first bed file (used during intersectBed)
my $anno_col=$ARGV[2];
my $anno_type;
my @colnames;

open FI,$ARGV[0] || die "sorry$!\n"; #bed overlap file produced by intersectBed
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    if($.==1){@colnames=@x;next};
    my $id=join("\t",@x[0..($bed_cols-1)]);
    
    if($x[$bed_cols] ne "."){ #any overlap
        my $reg=$x[$bed_cols+4-1];
        $rec{$id}{$reg}=$anno_col==4?1:($x[$bed_cols+4]);
        $regs{$reg}=1;
        }
}
close FI;

my @regs=keys%regs;
my $pre='NA';
open FI,$ARGV[0] || die "sorry$!\n"; #bed overlap file produced by intersectBed
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    if($.==1){print join("\t",@colnames,@regs),"\n";next}
    my $id=join("\t",@x[0..($bed_cols-1)]);
    next if $id eq $pre; #remove redundances because of intersectBed runing results
    my @out;
    map {
        my $reg=$_;
        my $out=defined $rec{$id}{$reg}?($rec{$id}{$reg}):"NA";
        if($out eq "NA" && $anno_col==4){$out=0}
        push(@out,$out);
         } @regs;
    print join("\t",$id,@out),"\n";
    $pre=$id;
}
close FI;
