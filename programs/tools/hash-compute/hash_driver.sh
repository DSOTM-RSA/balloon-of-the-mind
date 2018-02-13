#!/bin/bash

# hash-compute
# 08-02-2018
# compute and compare hashes of images in folders

# compute image hashes for directories
python hash_func.py --haystack oldImages/ --needles newImages/

# compare hashes between two locales
gawk -F, '
FNR==NR {a[NR]=$1; next};
{b[$1]=$0}
END{for (i in a) if (a[i] in b) print b[a[i]]}
' >HSH-MTCH.txt hay.txt needle.txt

# extract directory paths of matched pairs
awk '{$1=""; print $0}' HSH-MTCH.txt > MTCH-DIR.txt

# process temporary files
awk '{sub(/].*/,""); print}' MTCH-DIR.txt > DIR-PRC_00.txt # remove ] 
awk -F, '/,/{gsub(/ /, "",$0); print} ' DIR-PRC_00.txt > DIR-PRC_01.txt # remove spaces in lines with , 
sed "s/'//g" DIR-PRC_01.txt > DIR-PRC_02.txt # remove ' 
sed 's/,/\n/g' DIR-PRC_02.txt > DIR-PRC-FN.txt # seperate onto newlines


# not needed for same dir
#sed 's,^,/,' sub4.txt > dirs.txt # add / [escape it using , as delimeter in s/a/b/ expression]

# print messages
echo -e "[INFO]: finished labelling duplicates"
echo -e "[INFO]: printing first 10 duplicates..."
head -10 DIR-PRC-FN.txt

# delete duplicate folders :: BE CAREFUL with typos....
# xargs rm < dirs.txt


