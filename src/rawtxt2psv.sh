#!/bin/env bash
#
#### DESCRIPTION: Process raw .txt files from ../indata to .psv files
####              placed at ../outdata.

cd ../indata  || exit 1

## Process .txt files to psv files in Date Range: 2012-2017-2022
for file in 201[234567]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo "Processing file \"$file\"" 1>&2
  gawk -v year="$year" -f ../src/tax_2012_2017.awk "$file" > "../outdata/$outfile"
done

## Process .txt files to psv files in Date Range: 2018-2022

## Process 2018-2019 TXT files
for file in 201[89]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo "Processing file \"$file\"" 1>&2
  gawk -v year="$year" -f ../src/tax_2018_.awk "$file" > "../outdata/$outfile"
done

## Process 2020-2023 TXT files:
for file in 202[0123]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo "Processing file \"$file\"" 1>&2
  gawk -v year="$year" -f ../src/tax_2018_.awk "$file" > "../outdata/$outfile"
done


exit 0


