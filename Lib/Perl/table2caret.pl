#!/usr/bin/perl
use strict;
use warnings;
#my $multifile=$ARGV[0];

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
        print join("\t","ID",@x[5..$#x]),"\n"; 
        next
    };
    next if (length($x[3])>1 || length($x[4])>1);
    #print STDERR "it is dealing with $. now ...\n";
    my @out=();
    push(@out,join(":",@x[0..4]));
    map {
        if($colnames[$_]=~/RBP|ribosnitch|PFM\(CisBP\)|PFM\(RBPDB\)|targetScanS/){my $value=($x[$_] eq '.' || $x[$_] eq '-')?"No":"Yes";push(@out,$value)};
        if($colnames[$_] eq "RNAsnp"){my $value=$x[$_] >0.05?"No":"Yes";push(@out,$value)};
        if($colnames[$_]=~/CADD_phred|GERP|phyloP46way_placental/){my $value=($x[$_] eq '.' || $x[$_] eq '-')?"NA":$x[$_];push(@out,$value)};
        if($colnames[$_] eq "phastConsElements46way"){my $value=($x[$_]=~/lod=(\d+)/)?$1:"NA";push(@out,$value)};
        } 5..$#colnames;
    
	print join("\t", @out),"\n";
}
close FI;


        #if($colnames[$_] eq "ribosnitch"){my $value=$x[$_] eq '.'?"No":"Yes";push(@out,$value);next}
        #if($colnames[$_] eq "PFM(CisBP)"){my $value=$x[$_] eq '.'?"No":"Yes";push(@out,$value);next}
        #if($colnames[$_] eq "PFM(RBPDB)"){my $value=$x[$_] eq '.'?"No":"Yes";push(@out,$value);next}
        #if($colnames[$_] eq "targetScanS"){my $value=$x[$_] eq '-'?"No":"Yes";push(@out,$value);next}
        
        