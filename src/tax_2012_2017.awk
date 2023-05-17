        toekn
#### DESCRIPTION: This awk script first writes out a header line of the resulting pipe separated file.
####              It also sets up the record and field separators used to process the lower-hud (NY) tax data files
####              from 2012 to 2017, inclusive. It appears the tax data for these years is a pdf report that -- after text scraping --
####              appears to be broken into "pages" using a form-feed character, '\f'. The fields of such a record 
####              can now be thought of as begin described by a regular expression: " {4}*{94}". 
####              This is used as each parcel record is sandwiched between the pattern above followed by a parcel ID.
####              The parcel info now can be split into lines using and further processed to extract the information 
####              for a given parcel. Unfortunately the information format is inconsistent and we have to search over 
####              several lines for some of the pieces of info.
####
BEGIN{RS="\\f"        ; 
      FS=" {4}\\*{94}"; 
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
        split(lns[4], tn, "\\(|\\)"     ); # Split the 4th line to get the town info.
        split(tn[1], sw, ": "           ); # Split the first part of the town info to get the SWIS. 
        gsub(/[ \t]+$/, "", sw[2]       ); # Get the SWIS data.

        ## Now proceed to process each of the parcels for this page.
        ## The parcel data are contained in the fields from 2 to NF-1. 
        ## The first field was the header we just processed; the last field consists of blank lines.
        ## NOTE: "fields" on a given line are separated by at least three spaces.
        ##        Within a "field" data is packaged together separated by two spaces.
        for (i=2;i < NF; ++i) {
          printf("%s^%s^%s", year, sw[2], tn[2]); # Print the year, SWIS and town information. 
          split($i, lns, "\n"           ); # Split the parcel info into lines. 

          split(lns[2], addrs, "   +"   ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
          ln=length(addrs);
          printf("^%s", addrs[ln-2]     ); # Print the address.
          split(addrs[ln-1], acct, ": " );
          gsub(/[ \t]+/, "", acct[2]    );
          printf("^%s", acct[2]         ); # Print the account ID.
          split(lns[3], parcel, "   +"  ); # The third line has the parcel info. 
          split(parcel[2], pid, "  "    ); # Get the parcel ID.
          printf("^%s", pid[1]          ); # Print the parcel ID.
          printf("^%s", parcel[3]       ); # Get and print the parcel type.  
          split(parcel[3], LUC, " "     ); # Within in a "field" data is separated by two spaces.
          printf("^%s", LUC[1]          );
          split(lns[4], own1, "   +"    ); # Get the first owner.
          split(own1[2], ow1, "  "      );
          printf("^%s", ow1[1]          ); # Remove any extra characters.
          split(lns[5], own2, "   +"    ); # Get the second owner/address.
          split(own2[2], ow2, "  "      ); # Remove any extra characters.
          printf("^%s", ow2[1]          ); # Print out the second owner (could also be an address if no second owner).
          if (own2[3] ~ /ACREAGE/) {
            split(own2[3], acr, "  "    ); # Get the acreage info.
            printf("^%s", acr[2]        ); # Print the acreage size.
          } else {
            split(lns[6], l6info, "   +"); # Get the sixth line as it may contain the acreage info.
            if (l6info[3] ~ /ACREAGE/) {
              split(l6info[3], acr, "  "); 
              printf("^%s", acr[2]      );
            } else {
              printf("^"                );
            }
          } 

          ## Now get the Full market value of the parcel.
          ## This can be in any one of the lines 6,7, or 8.
          mkt_pat = "FULL MKT VAL  ([0-9,]+)";
          if (match(lns[5], mkt_pat, m)) {
          } else if (match(lns[6], mkt_pat, m)) { 
          } else if (match(lns[7], mkt_pat, m)) {
          } else if (match(lns[8], mkt_pat, m)) { 
          } else {
             match(lns[9], mkt_pat, m    ); 
          }
          gsub(/,/, "", m[1]             );
          printf("^%s", m[1]             );

          printf("\n"                    ); # Close out this record.

        } 
  }

