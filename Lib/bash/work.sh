#!/bin/bash
for file in `ls ./scratch-midway/psychEncode/datadownload/*/*/combined_merge_picked.hist`
do

regs=`cut -f 1,2,3 $file | uniq| wc -l`
echo "$file $regs"

done

