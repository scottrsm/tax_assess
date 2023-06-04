#!/bin/env bash

#### DESCRIPOTION: Process raw PDF Final_Assessment.pdf files
####               producing raw .txt files placed in the
####               directory ../outdata.

## Use Bash strict mode.
set -euo pipefail

## Temp file.
tmpFile=tmp.$$


## Set trap to remove temp file on exit.
trap 'rm -f $tmpFile' EXIT TERM INT QUIT

## Move to the data directory to process.
cd ../pdfdata

 ## Process PDF files: Date Range: 2012-2017
for file in 201[234567]*.pdf; do
  txtfile=${file/%.pdf/.txt}
  echo "Working on file, \"$file\"" 1>&2
  pdf2txt "$file" > "$txtfile"
  sed 's/\"//g' "$txtfile" > $tmpFile
  sed 's/ $/  /' "$tmpFile" > "$txtfile"
  mv "$txtfile" "../indata/$txtfile"
done

## Process PDF files: Date Range: 2018-2023
## Process 2018-2019 TXT files:
for file in 201[89]*.pdf; do
  txtfile=${file/%.pdf/.txt}
  echo "Working on file, \"$file\"" 1>&2
  pdftotext -layout "$file" 
  sed 's/\"//g' "$txtfile" > $tmpFile
  mv "$tmpFile" "../indata/$txtfile"
done

## Process PDF files: Date Range: 2020-2023
for file in 202[0123]*.pdf; do
  txtfile=${file/%.pdf/.txt}
  echo "Working on file, \"$file\"" 1>&2
  pdftotext -layout "$file" 
  sed 's/\"//g' "$txtfile" > $tmpFile
  mv "$tmpFile" "../indata/$txtfile"
  rm -f "$txtfile"
done


## Exit successfully
exit 0

 
