#!/bin/env bash
#
#### DESCRIPTION: Process raw .txt files (generated from raw pdf files)
####              from ../indata to .psv files placed at ../outdata.
####              NOTE: Script handles assessment files until 2029
####                    assuming no change in the format of the PDF files
####                    after 2024.

## Use Bash strict mode.
set -euo pipefail

## System Programs Used.
AWK=/bin/gawk

## Awk scripts used:
TAX_OLD_AWK=../src/tax_2012_2017.awk
TAX_NEW_AWK=../src/tax_2018_.awk


## Move to the input data directory.
cd ../indata  || exit 1

## Process .txt files to psv files in Date Range: 2012-2017.
for file in 201[234567]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo "Processing file \"$file\"" 1>&2
  $AWK -v year="$year" -f ${TAX_OLD_AWK} "$file" > "../outdata/$outfile"
done

## Process .txt files to psv files in Date Range: 2018-2019.
for file in 201[89]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo "Processing file \"$file\"" 1>&2
  $AWK -v year="$year" -f ${TAX_NEW_AWK} "$file" > "../outdata/$outfile"
done

## Process .txt files to psv files in Date Range: 2020-2029.
for file in 202[0-9]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo "Processing file \"$file\"" 1>&2
  $AWK -v year="$year" -f ${TAX_NEW_AWK} "$file" > "../outdata/$outfile"
done


exit 0


