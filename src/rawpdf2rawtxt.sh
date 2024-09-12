#!/bin/env bash

#### DESCRIPOTION: Process raw PDF Final_Assessment.pdf files
####               producing raw .txt files placed in the
####               directory ../outdata.
####               NOTE: Script handles assessment files until 2029
####                     assuming no change in the format of the PDF files
####                     after 2024.

## Use Bash strict mode.
set -euo pipefail

## Temp file.
tmpFile=tmp.$$

# System Programs Used.
MV=/bin/mv
PDF2TXT_OLD=/bin/pdf2txt
PDF2TXT_NEW=/bin/pdftotext
RM=/bin/rm
SED=/bin/sed


## Set trap to remove temp file on exit.
trap 'rm -f $tmpFile' EXIT TERM INT QUIT

## Move to the data directory to process.
cd ../pdfdata

## Process PDF files: Date Range: 2012-2017
for file in 201[234567]*.pdf; do
  txtfile=${file/%.pdf/.txt}
  echo "Working on file, \"$file\"" 1>&2
  ${PDF2TXT_OLD} "$file" > "$txtfile"
  $SED 's/\"//g' "$txtfile" > $tmpFile
  $SED 's/ $/  /' "$tmpFile" > "$txtfile"
  $MV "$txtfile" "../indata/$txtfile"
done

## Process PDF files: Date Range: 2018-2019
for file in 201[89]*.pdf; do
  txtfile=${file/%.pdf/.txt}
  echo "Working on file, \"$file\"" 1>&2
  ${PDF2TXT_NEW} -layout "$file" 
  $SED 's/\"//g' "$txtfile" > $tmpFile
  $MV "$tmpFile" "../indata/$txtfile"
  $RM -f "$txtfile"
done

## Process PDF files: Date Range: 2020-2029
for file in 202[0-9]*.pdf; do
  echo $file
  txtfile=${file/%.pdf/.txt}
  echo $txtfile
  echo "Working on file, \"$file\"" 1>&2
  ${PDF2TXT_NEW} -layout "$file" 
  $SED 's/\"//g' "$txtfile" > $tmpFile
  $MV "$tmpFile" "../indata/$txtfile"
  $RM -f "$txtfile"
done

## Exit successfully
exit 0

 
