#!/bin/bash

# name-randomiser
# 11-02-2018
# renames files randomly

# generate a random string based on md5sum
random_string() { 
  echo "$(date +%s%N)$RANDOM" | md5sum | awk '{print $1}' 
}


# set first argument to be directory to iterate through
tdir=$1

# find files :: insert string :: keep extensions
find $tdir -type f | while read FILE; do 
  EXTENSION=${FILE##*.}
  mv "$FILE" "$(dirname "$FILE")/$(random_string).$EXTENSION"
done
