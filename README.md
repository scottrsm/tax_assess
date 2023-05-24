## Project Overview
This project is concerned with processing land parcels of incorporated villages and unincorporated regions of Greenburg, New York, USA.
The incorporated villages of Greenburgh are:
- Ardsley
- Dobbs Ferry
- Elmsford
- Hastings
- Irvington
- Tarrytown

### Project Structure
- pdfdata -- Raw PDF data from Assessor's web site. File extension: *.pdf*.
- indata  -- Contains raw text data scraped from pdf files in directory *pdfdata*. File extension: *.txt*.
- outdata -- Processed *indata* files. File extension: *.psv*. 
- src     -- Contains shell and awk scripts to process raw TXT data files in directory *indata*
             and place processed PSV files to *outdata*.
- taxdb   -- Contains the SQL Lite database created from the outdata files.
             Also as the SQL Lite script create_taxrec used to create the database.



### Data Source
The data source is the Assessment records from the Hartsdale, NY town web site:
The data is currently stored as PDFs of reports on a yearly basis. The two most recent 
are stored at: [Current Assessments](https://www.greenburghny.com/169/Assessment-Rolls).

Previous years are stored at: [Historic Assessments](https://www.greenburghny.com/604/Past-Assessment-Rolls).

## Process Raw Parcel Data
The parcel data was obtained from the Harsdale Tax Assessor's office stored as PDFs.
There are 11 data files, one for each year from 2012 to 2022.
These files are stored in the directory *pdfdata*.
The files are converted to raw TXT files. As the dates 2012-2017 and 2018- have different 
formats, the conversion for each is different:
The code below has now been placed in the two scripts: src/rawpdf2rawtxt.sh, and rawtxt2psv.sh.
- PDF --> TXT:  Process PDF files to TXT files:
    - Date Range: 2012-2017  
      <pre> 
        cd pdfdata 

        ## Process 2012-2017 PDF files:
        for file in 201[234567]*.pdf; do
          txtfile=$(echo $file | sed 's/\.pdf$/.txt/')
          pdf2txt $file
          mv $txtfile ../indata/
        done
      </pre>

    - Date Range: 2018-2022
      <pre>
        cd pdfdata 

        ## Process 2018-2019 TXT files:
        for file in 201[89]*.pdf; do
          txtfile=$(echo $file | sed 's/\.pdf$/.txt/')
          pdftotext -layout $file 
          mv $txtfile ../indata/
        done

        ## Process 2020-2022 PDF files:
        for file in 202[012]*.pdf; do
          txtfile=$(echo $file | sed 's/\.pdf$/.txt/')
          pdftotext -layout $file 
          mv $txtfile ../indata/
        done
      </pre>
- TXT --> PSV: Process TXT files to PSV files:
         There are two different scripts: one for each date range.
    - Date Range: 2012-2017
        <pre>
        cd indata 

        for file in 201[234567]*.txt; do
          outfile=$(echo $file | sed 's/\.txt$/.psv/') 
          year=$(echo $file | sed 's/^\([0-9]\+\)_.*$/\1/')
          gawk -v year=$year -f ../src/tax_2012_2017.awk $file > ../outdata/$outfile
        done
      </pre>
    - Date Range: 2018-2022
     <pre>
        cd indata 

        ## Process 2018-2019 TXT files
        for file in 201[89]*.txt; do
          outfile=$(echo $file | sed 's/\.txt$/.psv/') 
          year=$(echo $file | sed 's/^\([0-9]\+\)_.*$/\1/')
          gawk -v year=$year -f ../src/tax_2018_.awk $file > ../outdata/$outfile
        done

        ## Process 2020-2022 TXT files:
        for file in 202[012]*.txt; do
          outfile=$(echo $file | sed 's/\.txt$/.psv/') 
          year=$(echo $file | sed 's/^\([0-9]\+\)_.*$/\1/')
          gawk -v year=$year -f ../src/tax_2018_.awk $file > ../outdata/$outfile
        done
      </pre>

### Output File Format
The processed files in the directory outdata have the following schema:

- Format:  SWIS, TOWN, ADDR, ACCT, PARCEL_ID, PARCEL_TYPE, LUC, OWN1, OWN2, ACCR, FULL_MKT_VAL 
- Field Descriptions:
    - This is the header of the pipe separated file that will be generated.
    - The fields are:
    - YEAR          -- The **year** of the record. **NOTE:** This field is passed in from the above shell scripts.
    - SWIS          -- The **SWIS** number for town of the parcel.
    - TOWN          -- The **town** name for the parcel.
    - ADDR          -- The **address** within the town.
    - ACCT          -- The **account number** for this parcel.
    - PARCEL_ID     -- The **parcel ID**. It is believed the first part of this string (or all of it) can be 
                       matched with the following regular expression pattern: '^[0-9]\.[0-9]+-[0-9]+0[0-9]+'
                       However, there is no dependence on this assumption in the code used to process the data.
    - PARCEL_TYPE   -- The **parcel type**; e.g., Single family residence, etc.
    - LUC           -- (L)and (U)se (C)ode for this parcel.
    - OWN1          -- The **first owner** (Or name of business)
    - OWN2          -- The **second owner** or address of property.
    - ACCR          -- The **acreage** of the property.
    - FULL_MKT_VAL  -- The **full market value** of the parcel -- land value + building value.

### Create Tax Assessment Database
Uses the SQL Lite script, taxdb/create_taxrec, to create SQL Lite database taxrec.db with one table, taxrec,
with schema/type: 

YEAR : INT, SWIS : INT, TOWN : TEXT, ADDR : TEXT

ACCT : TEXT, PARCEL_ID : TEXT, PARCEL_TYPE : TEXT, LUC : INT

OWN1 TEXT, OWN2 TEXT, ACCR FLOAT, FULL_MKT_VALUE INT



### Tax Assessment Analysis
The Jupyter notebook file, *src/Tax_Assessment.ipynb, analyzes the SQL-lite database and compares
the aggregated returns based on different aggregation and filtering methods.




