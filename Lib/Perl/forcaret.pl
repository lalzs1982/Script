#!/usr/bin/perl
use strict;
use warnings;

my %rec;
my @colnames;
my %ids;
open(FI,$ARGV[0]) || die "sorry,$!\n";
while (<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    
    if ($.==1)
    {
        @colnames=@x;
        next;
    };
    my $id=join(":",@x[0..4]);
    $ids{$id}=1;
    #push(@ids,$id);
    #my @out;
    map {
        #print STDERR "$_ is: $colnames[$_]\n";
        if($colnames[$_] eq 'RBP' || $colnames[$_] eq 'UTRcis'){if($x[$_] ne '.'){
        $rec{"$colnames[$_]($x[$_])"}{$id}='Yes'}}elsif($colnames[$_]=~/RBPDB|CisBP/){ 
            
        if($x[$_] ne '.:.'){my @yy=split/:/,$x[$_]; $rec{"$colnames[$_]($yy[0])"}{$id}=$yy[1];
                            }
        }elsif($colnames[$_] eq 'targetScanS'){
        if($x[$_]=~/(miR-.*)/){
            my @zz=split/\//,$1;
            $rec{"$colnames[$_]($zz[0])"}{$id}=1;
            if(scalar(@zz)>1){for my $z(@zz[1..$#zz]){$rec{"$colnames[$_](miR-$z)"}{$id}=1}}
            }
            }elsif($colnames[$_]=~/Ribosnitch/){$rec{$colnames[$_]}{$id}=($x[$_] eq '.')?'No':'Yes'}else{
            $rec{$colnames[$_]}{$id}=$x[$_]
        }
        } 5..$#colnames;
    
	#print join("\t",@x),"\n";
}
close FI;

my @colnamess=keys%rec;
print join("\t",'Coor',@colnamess),"\n";

for my $id(keys%ids)
{
    my @out;
    #my $nonzero=0;
    for my $col(@colnamess)
    {
        my $out=defined $rec{$col}{$id}?$rec{$col}{$id}:'No';
        if($col=~/RBPDB|CisBP/ && !defined $rec{$col}{$id}){$out=0};
        #if($out !=0){$nonzero++}
        push(@out,$out);
    }
    print join("\t",$id,@out),"\n";
}