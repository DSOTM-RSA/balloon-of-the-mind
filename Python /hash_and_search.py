#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 28 21:31:12 2017

@author: dan
"""

from imutils import paths
import argparse
import time
import sys
import cv2
import os
import json


# compute hashes for individual images
def dhash(image, hashSize = 8):
    
    # resize input image, to have a single column width
    resized = cv2.resize(image, (hashSize + 1, hashSize))
    
    # compute relative horizontal gradient
    diff = resized[:, 1:] > resized[:, :-1]

    # convert the difference image to a hash
    return sum([2 ** i for (i, v) in enumerate(diff.flatten()) if v])
    

# construct the argument parser, and the parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-a", "--haystack", required=True,
	help="dataset of images to search through (i.e., the haytack)")
ap.add_argument("-n", "--needles", required=True,
	help="set of images we are searching for (i.e., needles)")
args = vars(ap.parse_args())


# grab the paths to the needles and haystack directories
print ("[INFO]: computing hashes for haystack...")
haystackPaths = list(paths.list_images(args["haystack"]))
needlePaths = list(paths.list_images(args["needles"]))


# remove the `` character from an files containing a space
# assuming you are on a Unix machine
if sys.platform != "win32":
    haystackPaths = [p.replace("\\", "") for p in haystackPaths]
    needlePaths = [p.replace("\\", "") for p in needlePaths]


# get the base sub-directories for the needle paths
# initiliaze the directory that will map the image hash to corresponding image hashes
# start the timer
BASE_PATHS = set([p.split(os.path.sep)[-2] for p in needlePaths])
haystack = {}
start = time.time()


# loop over haystack paths
for p in haystackPaths:
    # load the image from disk
    image = cv2.imread(p)
    
    if image is None:
        continue
    
    # convert to grayscale
    image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    
    # calculate image hash
    imageHash = dhash(image)
    
    # update the haystack directory
    l = haystack.get(imageHash, [1])
    l.append(p)
    haystack[imageHash] = l


# show timing on hashing
# show timing for hashing haystack images, then start computing the
# hashes for needle images
print("[INFO] processed {} images in {:.2f} seconds".format(
	len(haystack), time.time() - start))
print("[INFO] computing hashes for needles...")


# loop over the needle paths
for p in needlePaths:
	# load the image from disk
	image = cv2.imread(p)
 
	# if the image is None then we could not load it from disk (so
	# skip it)
	if image is None:
		continue
 
	# convert the image to grayscale and compute the hash
	image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
	imageHash = dhash(image)
 
	# grab all image paths that match the hash
	matchedPaths = haystack.get(imageHash, [])
 
	# loop over all matched paths
	for matchedPath in matchedPaths:
     
		# extract the subdirectory from the image path
		b = p.split(os.path.sep)[-2]
 
		# if the subdirectory exists in the base path for the needle
		# images, remove it
		if b in BASE_PATHS:
			BASE_PATHS.remove(b)


# display directories to check
print("[INFO] check the following directories...")
 

# loop over each subdirectory and display it
for b in BASE_PATHS:
	print("[INFO] {}".format(b))
 
#################################### 
 ## Diagnostic info
 
print(type(haystack))
print(imageHash)
print(haystack)
print(type(matchedPaths))

with open('filename.txt', mode='wt', encoding='utf-8') as myfile:
    myfile.write('\n'.join(BASE_PATHS))

print(haystack.keys())



################

# export option 1
haystackJSON = {'haystack': haystack}

with open('file.txt', 'w') as file:
     file.write(json.dumps(haystackJSON))

     
# export option 2
# nice way of extracting hashes
fout = "library_of_hay.txt"
fo = open(fout, "w")

for k, v in haystack.items():
    fo.write(str(k) + ','+ str(v) + '\n')

fo.close()     

print("INFO","haystack hash-data is located here:",fout)