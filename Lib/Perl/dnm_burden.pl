#!/usr/bin/perl
use strict;
use warnings;

my %rec;
my %len;
my %cate;
#my %cate;
open FI,$ARGV[0]; #annotation and DNMs, should be unique each line
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my($id,$gp,$id_len,$gp_len,$total_len,$cate,$dnm_s)=@x[3,4,5,6,7,13,14];
    my $dnm=join("\t",@x[8..10]);
    
    $rec{'id'}{$id}{$cate}{$dnm}=1;
    $rec{'gp'}{$gp}{$cate}{$dnm}=1;
    $rec{'total'}{'total'}{$cate}{$dnm}=1;
    $len{'id'}{$id}=$id_len;
    $len{'gp'}{$gp}=$gp_len;
    $len{'total'}{'total'}=$total_len;
    
    #$rec{'All'}{'All'}{$cate}{$dnm}=1;
    $cate{$cate}=$dnm_s;
}
close FI;

#my @cate=keys%cate;
my @cate=qw(ASD Control); #keys%cate;
#my @cate=qw(Case Control); #keys%cate;

print join("\t","Cate","Elements",$cate[0],"all",$cate[1],"all","Reg_len"),"\n";

for my $k(qw(total gp id))
{
    for my $s(keys%{$rec{$k}})
    {
        my @nums=();
        for my $c(@cate)
        {
            if(defined $rec{$k}{$s}{$c}){push(@nums,scalar(keys%{$rec{$k}{$s}{$c}}))}else{push(@nums,0)};
            push(@nums,$cate{$c});
        }
        push(@nums,$len{$k}{$s});
        #next if($nums[0]+$nums[2]<1);
        print join("\t",$k,$s,@nums),"\n";
    }
}
