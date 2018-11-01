#!/usr/bin/perl
use strict;
use warnings;
#this script convert relative coordinates on transcripts to absolute coordinates on genome, read in gff format
#for example /project2/xinhe/zhongshan/data/gencode.v27.chr_patch_hapl_scaff.basic.annotation.gff3 
# one could define regions, such as exon, CDS or UTR etc. all regions will be produced
my $cate='three_prime_UTR';
open FI,$ARGV[0] || die "$!\n";
#open FI, "/project2/xinhe/zhongshan/data/gencode.v27.chr_patch_hapl_scaff.basic.annotation.gff3" || die "$!\n";

my %rec;
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    next if $x[2] ne $cate;
    $_=~/transcript_id=(.*?);/; my $id=$1;
    my($chr,$cate,$start,$end,$str)=@x[0,2,3,4,6];
    $rec{$cate}{$id}{$str}{$chr}{$start}=$end;
}
close FI;

for my $cate(keys%rec)
{
    for my $id(keys%{$rec{$cate}})
    {    
        for my $str(keys%{$rec{$cate}{$id}})
        {
            for my $chr(keys%{$rec{$cate}{$id}{$str}})
            {
                my @starts= keys%{$rec{$cate}{$id}{$str}{$chr}};
                my @starts_sorted=$str eq '+'?(sort {$a<=>$b} @starts):(sort {$b<=>$a} @starts);

                my $relpos=1;
                if($str eq '+'){
                    map {
                        my $start1=$_;my $end1=$rec{$cate}{$id}{$str}{$chr}{$_};
                        map {
                            print join("\t",$id,$cate,$relpos++,$chr,$str,$_),"\n";
                            } ($start1..$end1);
                        } @starts_sorted;
                }else{
                    map {
                        my $start1=$_;my $end1=$rec{$cate}{$id}{$str}{$chr}{$_};
                        map {
                            print join("\t",$id,$cate,$relpos++,$chr,$str,$_),"\n";
                            } reverse($start1..$end1);
                        } @starts_sorted;
                }
            }
        }
    }
}