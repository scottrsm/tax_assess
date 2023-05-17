
#### DESCRIPTION: This awk script first writes out a header line of the resulting pipe separated file.
####              It also sets up the record and field separators used to process the lower-hud (NY) tax data files
####              from 2012 to 2017, inclusive. It appears the tax data for these years is a pdf report that -- after text scraping --
####              appears to be broken into "pages" using a form-feed character, '\f'. The fields of such a record 
####              can now be thought of as beginning after the regular expression: "\*{66}". 
####              This is used as each parcel record is sandwiched between the pattern above followed by a parcel ID.
####              The parcel info now can be split into lines and further processed to extract the information 
####              for a given parcel. 
####
BEGIN{RS="\\f"     ; 
      FS="\\*{66} "; 
      ## This is the header of the pipe separated file that will be generated.
      ## The fields are:
      ## YEAR          -- The Year of the record. **NOTE:** This field is passed in from a shell script.
      ## SWIS          -- The SWIS number for town of the parcel.
      ## TOWN          -- The Town name for the parcel.
      ## ADDR          -- The address within the town.
      ## ACCT          -- The Account number for this parcel.
      ## PARCEL_ID     -- The parcel ID. It is believed that has a form that matches the regular expression pattern: '^[0-9]\.[0-9]+-[0-9]+0[0-9]+'
      ##                  However, there is no dependence on this assumption in the code below.
      ## PARCEL_TYPE   -- The parcel type; e.g., Single family residence, etc.
      ## LUC           -- (L)and (U)se (C)ode for this parcel.
      ## OWN1          -- The first owner (Or name of business)
      ## OWN2          -- The second owner or address of property.
      ## ACCR          -- The acreage of the property.
      ## FULL_MKT_VAL  -- The full market value of the parcel -- land value + building value.
      printf("%s^%s^%s^%s^%s^%s^%s^%s^%s^%s^%s^%s\n", "YEAR", "SWIS", "TOWN", "ADDR", "ACCT", "PARCEL_ID", "PARCEL_TYPE", "LUC", "OWN1", "OWN2", "ACCR", "FULL_MKT_VAL")}; 
 {
    ## The first field of the record is the header for all of the tax records on the "page".
    split($1, lns, "\n"             ); # Split the first field into lines.
    split(lns[4], tn, " "           ); # Split the 4th line to get the town info.

    for (i=2;i <= NF; ++i) {
      printf("%s^%s^%s", year, tn[3], tn[4]); # Print the year, SWIS and town information.
      split($i, lns, "\n"           ); # Split the parcel info into lines. 
      split(lns[6], addrs, "   +"   ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
      printf("^%s", addrs[1]        ); # Print the address.
      split(lns[2], acct, "   +"    ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
      printf("^%s", acct[4]         ); # Print the parcel account id.
      split(lns[3], pid, "   +"     ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
      printf("^%s", pid[1]          ); # Print the parcel ID.
      printf("^%s", pid[2]          ); # Print the parcel type.
      split(pid[2], luc, " "        ); # Extract LUC. 
      printf("^%s", luc[1]          ); # Print the parcel LUC.
      split(lns[4], own1, "   +"    ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
      printf("^%s", own1[1]         ); # Print Owner 1.
      split(lns[5], info5, "   +"   ); # Get the line 5 info.
      printf("^%s", info5[1]        ); # Print Owner 2.
      split(info5[2], accr, " "     ); # Get the acreage.
      printf("^%s", accr[2]         ); # Print the parcel acreage.
      if (lns[9] ~ /FULL MKT VAL/) {
        split(lns[9], fmktv, "   +" ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
        gsub(/,/, "", fmktv[3]      ); # Remove "," from the full market value. 
        printf("^%s", fmktv[3]      ); # Print the Full Market Value.
      } else {
        split(lns[10], fmktv, "   +"); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
        gsub(/,/, "", fmktv[3]      ); # Remove "," from the full market value. 
        printf("^%s", fmktv[3]      ); # Print the Full Market Value.
      }

      printf("\n"                   ); # Close out this record. 

    }
 }
