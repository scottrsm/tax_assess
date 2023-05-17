#!/bin/env bash
#
#### DESCRIPTION: Process raw .txt files from ../indata to .psv files
####              placed at ../outdata.

cd ../indata 

## Process .txt files to psv files in Date Range: 2012-2017-2022
for file in 201[234567]*.txt; do
  outfile=$(echo $file | sed 's/\.txt$/.psv/') 
  year=$(echo $file | sed 's/^\([0-9]\+\)_.*$/\1/')
  echo "Processing file \"$file\"" 1>&2
  gawk -v year=$year -f ../src/tax_2012_2017.awk $file > ../outdata/$outfile
done

## Process .txt files to psv files in Date Range: 2018-2022

## Process 2018-2019 TXT files
for file in 201[89]*.txt; do
  outfile=$(echo $file | sed 's/\.txt$/.psv/') 
  year=$(echo $file | sed 's/^\([0-9]\+\)_.*$/\1/')
  echo "Processing file \"$file\"" 1>&2
  gawk -v year=$year -f ../src/tax_2018_.awk $file > ../outdata/$outfile
done

## Process 2020-2022 TXT files:
for file in 202[012]*.txt; do
  outfile=$(echo $file | sed 's/\.txt$/.psv/') 
  year=$(echo $file | sed 's/^\([0-9]\+\)_.*$/\1/')
  echo "Processing file \"$file\"" 1>&2
  gawk -v year=$year -f ../src/tax_2018_.awk $file > ../outdata/$outfile
done


exit 0


