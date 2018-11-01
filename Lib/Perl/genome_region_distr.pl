#!/usr/bin/perl
my %rec;
my @groups=@ARGV[1..$#ARGV]; #columns uses as groups
my %gp_rec;
open FI,$ARGV[0]; #annovar produced multianno.txt file
while(<FI>)
{
    next if $.==1;
    chomp;
    my @x=split/\t/;
    my $gp=join(":",@x[@groups]);
    my $cate=join(":",@x[5,8]);
    $rec{$cate}{$gp}+=1;
    $gp_rec{$gp}=1;
}
close FI;

#print join("\t",keys%gp_rec),"\n";
for my $cate(keys%rec)
{
    #my @rec;
    for my $gp(keys%gp_rec)
    {
        $rec{$cate}{$gp}=defined $rec{$cate}{$gp}?$rec{$cate}{$gp}:0;
        #push(@rec,$rec{$cate}{$gp});
    }
    #print join("\t",$cate,@rec),"\n";
}

my %rec1;
my @cate1=('intergenic', 'intronic', 'ncRNA','synonymous','nonsynonymous','UTR3','UTR5','stopgain','stoploss','splicing','upstream','downstream');
    for my $gp(keys%gp_rec)
    {
        for my $cate(@cate1)
        {
            map {
                if($_=~/$cate/){$rec1{$cate}{$gp}+=$rec{$_}{$gp}}
                } keys%rec;
        }
    }

print join("\t",keys%gp_rec),"\n";
for my $cate(@cate1)
{
    my @rec;
    for my $gp(keys%gp_rec)
    {
        $rec1{$cate}{$gp}=defined $rec1{$cate}{$gp}?$rec1{$cate}{$gp}:0;
        push(@rec,$rec1{$cate}{$gp});
    }
    print join("\t",$cate,@rec),"\n";
}
