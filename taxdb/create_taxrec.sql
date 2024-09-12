create table taxrec('YEAR' INT, 'SWIS' INT, 'TOWN' TEXT, 'ADDR' TEXT, 
                    'ACCT' TEXT, 'PARCEL_ID' TEXT, 'PARCEL_TYPE' TEXT, 'LUC' INT, 
                    'OWN1' TEXT, 'OWN2' TEXT, 'ACCR' FLOAT, 'LAND_VAL' INT, 'FULL_MKT_VALUE' INT);
.mode csv
.headers on
.separator ROW "\n"
.separator "^"

.import --skip 1 ../outdata/2012_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2013_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2014_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2015_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2016_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2017_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2018_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2019_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2020_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2021_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2022_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2023_Final_Assessment.psv taxrec
.import --skip 1 ../outdata/2024_Final_Assessment.psv taxrec




