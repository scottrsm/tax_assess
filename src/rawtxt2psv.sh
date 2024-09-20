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
GREP=/bin/grep

## Awk scripts used:
TAX_OLD_AWK=../src/tax_2012_2017.awk
TAX_NEW_AWK=../src/tax_2018_.awk


## Move to the input data directory.
cd ../indata  || exit 1

## Process .txt files to psv files in Date Range: 2012-2017.
## A record is a series of lines. The lines become, effectively, the fields
## of the raw record. From here, we take a given line and split it into
## sub-fields. This can sometimes fail as the delimiter for the split is 3 
## or more spaces and in some cases a field "spills" into the next as the next
## field is only separated by 2 spaces. We need to use the 3 spaces as a delimiter
## because two spaces are used to deliniate sub-sub-fields.
## In these cases, we end up with the string, "BADRECORD", in one of the fields.
## Below, we filter these out from the final data set.
## NOTE: In some cases we can't determine some of the fields we provide the following
## defaults:
##  1). acreage to: "0".
##  2). LUC to: "0".
##  3). account number to: "XXXXXX".
##  4). Land Val to: "0".
##  5). FULL MKT VAL to: "-10000".
for file in 201[234567]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo "Processing file \"$file\"" 1>&2
  $AWK -v year="$year" -f ${TAX_OLD_AWK} "$file" | $GREP -v BADRECORD > "../outdata/$outfile"
done

## Process .txt files to psv files for Date Range: 2018-2019 and 2020-2029.
## In some cases we can't determine some of the fields we provide the following
## defaults:
## 1). Acreage: "0".
## 2). LUC to: "0".
## 3). account number to: "XXXXXX".
## 4). Land VAL: "0".
## 5). FULL MKT VAL: "-10000" or "-20000" (if not found on the later lines)


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


