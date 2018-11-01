#!/usr/bin/perl
my $relationship=$ARGV[0];
my $genes=$ARGV[1];

my %rec;
open FI,$relationship || die "sorry$!\n";
#print STDERR "$relationship\n";
while(<FI>)
{
    next if $.==1;
    chomp;
    my @x=split/\t/,$_;
    my($id,$gene,$type)=@x[0,2,4];
    #print STDERR "$id\n";
    
    $rec{$id}="$gene\t$type";
}
close FI;

open FI,$genes;
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my $id=$x[10];
    #print STDERR "$id\n";
    my $gene=defined($rec{$id})?$rec{$id}:"NULL\tNULL";
    print join("\t",$_,$gene),"\n";
}
close FI;
