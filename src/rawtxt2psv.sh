#### DESCRIPTION: Process raw .txt files (generated from raw pdf files)
####              from ../indata to .psv files placed at ../outdata.
####              NOTE: Script handles assessment files until 2029
####                    assuming no change in the format of the PDF files
####                    after 2024.
#### NOTE: There are currently two file formats for the assessment data.
####       The first starts at 2012 and ends at 2017.
####       The second format starts at 2018.
####       The processing for both formats is simular, but not the same.
####       There is a problem with the older format in that sub-fields on a 
####       line of the scraped text are delimited by three or more spaces.
####       However, in some cases, the text of an address or something else 
####       potentially verbose willl leave only two spaces until the next sub-field.
####       In this case the associated awk script, tax_2012_2017.awk breaks.
####       Downstream this will mean that one or more of the field entries in 
####       the resulting .psv file will have the string, "BAD_RECORD".

## Use Bash strict mode.
set -euo pipefail

## System Programs Used.
AWK=/bin/gawk
CUT=/bin/cut
GREP=/bin/grep
MV=/bin/mv
RM=/bin/rm
SORT=/bin/sort

## Awk scripts used.
FIX_LUC_AWK=../src/fix_luc.awk
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
## In these cases, we end up with the string, "BAD_RECORD", in one of the fields.
## Below, we filter these out from the final data set.
## NOTE: In some cases we can't determine some of the fields we provide the following
## defaults:
##  1). acreage to: "0".
##  2). LUC to: "0".
##  3). account number to: "XXXXXX".
##  4). Land Val to: "0".
##  5). FULL MKT VAL to: "-10000".

echo -e "\n\nProcessing TXT files for 2012-2017..." >&2
for file in 201[234567]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo -e "\tProcessing file \"$file\"" >&2
  $AWK -v year="$year" -f ${TAX_OLD_AWK} "$file" > "../outdata/$outfile"
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
echo -e "\n\nProcessing TXT files for 2018-2019..." >&2
for file in 201[89]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo -e "\tProcessing file \"$file\"" >&2
  $AWK -v year="$year" -f ${TAX_NEW_AWK} "$file" > "../outdata/$outfile"
done

## Process .txt files to psv files in Date Range: 2020-2029.
echo -e "\n\nProcessing TXT files for 2020-2029..." >&2
for file in 202[0-9]*.txt; do
  outfile=${file/%.txt/.psv}
  year=${outfile:0:4}
  echo -e "\tProcessing file \"$file\"" >&2
  $AWK -v year="$year" -f ${TAX_NEW_AWK} "$file" > "../outdata/$outfile"
done

cd ../outdata || exit 2

## Add a trap handler to remove the temoprary files.
trap "$RM -f temp1.$$ temp2.$$" EXIT QUIT TERM INT

echo -e "\n\nPost Processing PSV files..." >&2
echo "LUC^PARCEL_TYPE" > LUC_TABLE.psv
for file in *Final_Assessment.psv; do
	echo -e "\tProcessing file $file..." >&2
	$CUT -d"^" -f1,2,3,4,5,6,7,9,10,11,12,13 $file > temp1.$$
	$CUT -d"^" -f7,8 $file | tail --lines=+2 >> temp2.$$
	$MV temp1.$$ $file
done

echo -e "\n\nFixing LUC_TABLE.psv..." >&2
$SORT temp2.$$ | uniq >> temp1.$$
$AWK -f ${FIX_LUC_AWK} temp1.$$ >> LUC_TABLE.psv

exit 0


