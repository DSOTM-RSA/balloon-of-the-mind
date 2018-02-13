#!/bin/bash

# image-resizer
# 13-02-2018
# resize images in current directory
# example usage: ./resizer_driver.sh /home/dan/Desktop/df/thumbs/ 25% *

# set first argument to be directory to iterate through
odir=$1
size=$2
type=$3

# reduce all jpgs
mogrify -path "$odir" -resize "$size" "$type"

# print helper message
echo -e "[PROGRESS]:: creating thumbnails..."

# wait for files
sleep 2
echo -e "[INFO]:: resizing complete"
