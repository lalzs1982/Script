#!/usr/bin/perl
use strict;
use warnings;

my $cut=$ARGV[1];

my $pos0=0;
my $chr0='NA';
my $pos1=0;
my $chr1='NA';


open FI,$ARGV[0] || die "sorry$!\n"; #bed files with depth and coordinates sorted
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my $chr=$x[0];
    my $pos=$x[1]+$x[3]-1;
    my $dep=$x[4];
    if($.==1){$pos0=$pos;
        $chr0=$chr;
        $pos1=$pos;
        $chr1=$chr;next}
    
    if($chr eq $chr1 && $pos==$pos1+1 && $dep>=$cut)
    {
        #print "$. $_ : continuous\n";
        $pos1++;
    }else{
        
        if($dep>=$cut){
            
            if($pos1-$pos0>50){print join("\t",$chr0,$pos0,$pos1),"\n"};
            #if($pos1-$pos0>2){print join("\t","$. $_ :  output here:",$chr0,$pos0,$pos1),"\n"};
            #print "$. $_ :  reset here\n";
        $pos0=$pos;
        $chr0=$chr;
        $pos1=$pos;
        $chr1=$chr;}
    }
}
print join("\t",$chr0,$pos0,$pos1),"\n";

close FI;
