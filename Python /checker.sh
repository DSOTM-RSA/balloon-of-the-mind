#!/bin/bash

# run python script
python hash_and_search.py --haystack oldImages/ --needles newImages/


# compare hashes between two locales
gawk -F, '
FNR==NR {a[NR]=$1; next};
{b[$1]=$0}
END{for (i in a) if (a[i] in b) print b[a[i]]}
' >matches.txt hay.txt needle.txt


# extract directories of matched pairs
awk '{$1=""; print $0}' matches.txt > matches_copy.txt


# processing temp files
awk '{sub(/].*/,""); print}' matches_copy.txt > sub1.txt # remove ] 
awk -F, '/,/{gsub(/ /, "",$0); print} ' sub1.txt > sub2.txt # remove spaces in lines with , 
sed "s/'//g" sub2.txt > sub3.txt # remove ' 
sed 's/,/\n/g' sub3.txt > sub4.txt # seperate onto newlines


# not needed for same dir
#sed 's,^,/,' sub4.txt > dirs.txt # add / [escape it using , as delimeter in s/a/b/ expression]

# print messages
echo -e "[INFO]: finished labelling duplicates"
echo -e "[INFO]: printing first 10 duplicates..."
head -10 dirs.txt


# delete duplicate folders :: BE CAREFUL with typos....
# xargs rm < dirs.txt


