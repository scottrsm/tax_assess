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
             Also as the SQL Lite script create_taxrec.sql used to create the database.



### Data Source
The data source is the Assessment records from the Hartsdale, NY town web site:
The data is currently stored as PDFs of reports on a yearly basis. The two most recent 
are stored at: [Current Assessments](https://www.greenburghny.com/169/Assessment-Rolls).

Previous years are stored at: [Historic Assessments](https://www.greenburghny.com/604/Past-Assessment-Rolls).

## Process Raw Parcel Data
The parcel data was obtained from the Harsdale Tax Assessor's office stored as PDFs.
There are 13 data files, one for each year from 2012 to 2024.
These files are stored in the directory *pdfdata*.
The files are converted to raw TXT files. As the dates 2012-2017 and 2018- have different 
formats, the conversion for each is different:
Procedure:
1.) cd src
2.) ./rawpdf2rawtxt.sh
3.) ./rawtxt2psv.sh

**NOTE (missing file):** `src/rawtxt2psv.sh` references an awk script, `../src/fix_luc.awk`,
used in its post-processing step to build `outdata/LUC_TABLE.psv`. This file is **not currently
present** anywhere in this repository. Until `fix_luc.awk` is restored/added, the
`fix_luc.awk`-dependent portion of `rawtxt2psv.sh` (the "Fixing LUC_TABLE.psv..." step) will fail.

### Output File Format
After running the two scripts above, 
the processed files in the directory outdata have the following schema:

- Format:  YEAR, SWIS, TOWN, ADDR, ACCT, PARCEL_ID, LUC, OWN1, OWN2, ACCR, LAND_VAL, FULL_MKT_VAL
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
    - LUC           -- (L)and (U)se (C)ode for this parcel.
    - OWN1          -- The **first owner** (Or name of business)
    - OWN2          -- The **second owner** or address of property.
    - ACCR          -- The **acreage** of the property.
    - LAND_VAL      -- The **assessed land value** of the parcel.
    - FULL_MKT_VAL  -- The **full assessed value** of the parcel -- land value + building value.

**NOTE:** The awk scripts (`src/tax_2012_2017.awk` and `src/tax_2018_.awk`) initially emit a
13-field record that also includes `PARCEL_TYPE` (the parcel type; e.g., Single family residence,
etc.), positioned right after `PARCEL_ID`/before `LUC`. However, `src/rawtxt2psv.sh` post-processes
each `*_Final_Assessment.psv` file with `cut` to drop the `PARCEL_TYPE` column from the main file
(giving the 12-field schema above), and instead writes the distinct `LUC`/`PARCEL_TYPE` pairs out
to a separate file, `outdata/LUC_TABLE.psv` (schema: `LUC^PARCEL_TYPE`). This lets `PARCEL_TYPE`
be looked up per parcel via a join on `LUC` rather than being repeated in every record.

### Create Tax Assessment Database
Use the SQL Lite script, taxdb/create_taxrec.sql, to create SQL Lite database taxrec.db with two
tables, taxrec and luc, as follows:
1. cd taxdb
2. sqlite3 taxrec.db
   .read create_taxrec.sql
3. Exit from sqlite3 shell

The table taxrec will be created in the database taxdb/taxrec.db with schema/type: 

YEAR : INT, SWIS : INT, TOWN : TEXT, ADDR : TEXT

ACCT : TEXT, PARCEL_ID : TEXT, LUC : INT

OWN1 : TEXT, OWN2 : TEXT, ACCR : FLOAT, LAND_VAL : INT, FULL_MKT_VALUE : INT

The table luc will also be created in the database taxdb/taxrec.db (loaded from
outdata/LUC_TABLE.psv) with schema/type:

LUC : INT, PARCEL_TYPE : TEXT


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
- python -m py_compile tax_utils.py

The directory src/utils contains two alternative implementations of the same utility functions:
- tax_utils.py     -- The default implementation, based on numpy/pandas.
- tax_jax_utils.py -- An optional, JAX-accelerated implementation (uses jax.numpy and the
                       jax_vec_analytics module in place of numpy and vec_analytics, respectively).

By default, src/Tax_Assessment.ipynb imports tax_utils. If you want to use the JAX-based path
instead, byte-compile it as well:
- python -m py_compile tax_jax_utils.py

and, in the notebook, comment out the `import tax_utils as utils` line and uncomment the
`#import tax_jax_utils as utils` line instead. Using the JAX path requires jax and
jax_vec_analytics to be installed/importable in addition to the packages needed for tax_utils.

Currently, the vec_analysis python module is in a separate repo, vec_analysis, on the scottrsm github site.


Version: 1.5
