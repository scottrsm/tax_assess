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
There are 12 data files, one for each year from 2012 to 2023.
These files are stored in the directory *pdfdata*.
The files are converted to raw TXT files. As the dates 2012-2017 and 2018- have different 
formats, the conversion for each is different:
Procedure:
1.) cd src
2.) ./rawpdf2rawtxt.sh
3.) ./rawtxt2psv.sh

### Output File Format
After running the two scripts above, 
the processed files in the directory outdata have the following schema:

- Format:  SWIS, TOWN, ADDR, ACCT, PARCEL_ID, PARCEL_TYPE, LUC, OWN1, OWN2, ACCR, LAND_VAL, FULL_MKT_VAL 
- Field Descriptions:
    - This is the header of the pipe separated file that will be generated.
    - The fields are:
    - YEAR          -- The **year** of the record. **NOTE:** This field is passed in from the above shell scripts.
    - SWIS          -- The **SWIS** number for town of the parcel.
    - TOWN          -- The **town** name for the parcel.
    - ADDR          -- The **address** within the town.
    - ACCT          -- The **account number** for this parcel.
    - PARCEL_ID     -- The **parcel ID**. It is believed the first part of this string (or all of it) can be 
                       matched with the following regular expression pattern: '^[0-9]\.[0-9]+-[0-9]+0[0-9]+' .
                       However, there is no dependence on this assumption in the code used to process the data.
    - PARCEL_TYPE   -- The **parcel type**; e.g., Single family residence, etc.
    - LUC           -- (L)and (U)se (C)ode for this parcel.
    - OWN1          -- The **first owner** (Or name of business)
    - OWN2          -- The **second owner** or address of property.
    - ACCR          -- The **acreage** of the property.
    - LAND_VAL      -- The **assessed land value** of the parcel.
    - FULL_MKT_VAL  -- The **full assessed value** of the parcel -- land value + building value.

### Create Tax Assessment Database
Use the SQL Lite script, taxdb/create_taxrec, to create SQL Lite database taxrec.db with one table, taxrec
as follows:
1. cd taxdb
2. sqlite3 taxrec.db
   .read create_taxrec.sql
3. Exit from sqlite3 shell

The table taxrec will be created in the database taxdb/taxrec.db with schema/type: 

YEAR : INT, SWIS : INT, TOWN : TEXT, ADDR : TEXT

ACCT : TEXT, PARCEL_ID : TEXT, PARCEL_TYPE : TEXT, LUC : INT

OWN1 : TEXT, OWN2 : TEXT, ACCR : FLOAT, LAND_VAL : INT, FULL_MKT_VALUE : INT


### Tax Assessment Analysis
The Jupyter notebook file, *src/Tax_Assessment.ipynb, analyzes the SQL-lite database and compares
the aggregated returns (and cumulative returns) based on different aggregation and filtering methods.

**NOTE:** To ensure that you have access to the python libraries used in the notebook, you may 
need to run bash within a given shell and set and export the environment variable
PYTHONPATH, appropriately, before launching "jupyter lab".
For instance, export PYTHONPATH=<existing-python-path>:<path-to-tax_assessement_project>/src/utils:<path-to-vec_analysis>
With this path one gets access to the tax_utils module and the vec_analysis module needed by tax_utils.
You will also need to do: 
- cd src/utils
- python -m py_compile tax_anal.py
- python -m py_compile tax_utils.py

Currently, the vec_analysis python module is in a separate repo, vec_analysis, on the scottrsm github site.


Version: 1.5
