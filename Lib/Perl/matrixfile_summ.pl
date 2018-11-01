#!/usr/bin/perl
use strict;
use warnings;


my %rec;
my %rec1;
my @colnames;
open(FI,$ARGV[0]) || die "sorry,$!\n";
while (<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    
    if ($.==1)
    {
        @colnames=@x;
        next;
    }
    my $coor=join(":",@x[0..4]);
    
    map {if ($x[$_]=~/[A-Za-z0-9]/){
        next if($colnames[$_]=~/trans-factor/ && $x[$_]=~/mir|let/i);
        next if($colnames[$_] eq 'CADD_phred' && $x[$_]<10);
        next if($colnames[$_] eq 'GERP++_RS' && $x[$_]<2);
        #next if($colnames[$_] eq 'phyloP46way_placental' && $x[$_]<);
        $rec{$colnames[$_]}{$coor}=$x[$_];$rec1{$coor}{$colnames[$_]}=$x[$_]}} 5..$#x;
    
    if((defined $rec1{$coor}{'RBPbinding(CisBP-RNA)'} && !defined $rec1{$coor}{'RBPbinding_withmutation(CisBP-RNA)'})
       ||(!defined $rec1{$coor}{'RBPbinding(CisBP-RNA)'} && defined $rec1{$coor}{'RBPbinding_withmutation(CisBP-RNA)'})       
       ){$rec{"PredictedRBchange(CisBP-RNA)"}{$coor}="$rec1{$coor}{'RBPbinding(CisBP-RNA)'} -> $rec1{$coor}{'RBPbinding_withmutation(CisBP-RNA)'}";
         $rec1{$coor}{"PredictedRBchange(CisBP-RNA)"}=$rec{"PredictedRBchange(CisBP-RNA)"}{$coor}}
    
    if((defined $rec1{$coor}{'RBPbinding(RBPDB)'} && !defined $rec1{$coor}{'RBPbinding_withmutation(RBPDB)'})
       ||(!defined $rec1{$coor}{'RBPbinding(RBPDB)'} && defined $rec1{$coor}{'RBPbinding_withmutation(RBPDB)'})       
       ){$rec{"PredictedRBchange(RBPDB)"}{$coor}="$rec1{$coor}{'RBPbinding(RBPDB)'} -> $rec1{$coor}{'RBPbinding_withmutation(RBPDB)'}";
         $rec1{$coor}{"PredictedRBchange(RBPDB)"}=$rec{"PredictedRBchange(RBPDB)"}{$coor}}
    
}
close FI;

foreach my $cn(keys%rec)
{
    print join("\t",$cn,scalar(keys%{$rec{$cn}})),"\n";
}


my %summ;
foreach my $coors(keys%rec1)
{
    my @cn_comb=();
    map {if (defined $rec1{$coors}{$_}){push(@cn_comb,$_)}} @colnames;
    $summ{join(',',@cn_comb)}+=1;
}

for my $kk(keys%summ)
{
    print join("\t",$kk,$summ{$kk}),"\n";
}
