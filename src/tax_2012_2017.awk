#### DESCRIPTION: This awk script first writes out a header line of the resulting pipe separated file.
####              It also sets up the record and field separators used to process the lower-hud (NY) tax data files
####              from 2012 to 2017, inclusive. It appears the tax data for these years is a pdf report that -- after text scraping --
####              appears to be broken into "pages" using a form-feed character, '\f'. The fields of such a record 
####              can now be thought of as beginning after the lines that look like: *******<PARCEL-ID>*******.
####              The parcel info now can be split into lines and further processed to extract the information 
####              for a given parcel. Unfortunately the information format is inconsistent and we have to search over 
####              several lines for some of the pieces of data.
####
BEGIN{RS="\\f"        ; 
      FS=" *\\*+ [0-9.-]+ \\*+ *\n"
      ## This is the header of the pipe separated file that will be generated.
      ## The fields are:
      ## YEAR          -- The Year of the record. **NOTE:** This field is passed in from a shell script.
      ## SWIS          -- The SWIS number for town of the parcel.
      ## TOWN          -- The Town name for the parcel.
      ## ADDR          -- The address within the town.
      ## ACCT          -- The Account number for this parcel.
      ## PARCEL_ID     -- The parcel ID. It is believed that has a form that matches the regular expression pattern: '^[0-9]\.[0-9]+-[0-9]+0[0-9]+'
      ##                  However, there is no dependence on this assumption in the code below.
      ## LUC           -- (L)and (U)se (C)ode for this parcel.
	  ## PARCEL_TYPE   -- The type of parcel for the LUC.
      ## OWN1          -- The first owner (Or name of business)
      ## OWN2          -- The second owner or address of property.
      ## ACCR          -- The acreage of the property.
	  ## LAND_VAL      -- The assessed value of the land of the parcel.
      ## FULL_MKT_VAL  -- The full assessed value of the parcel -- land value + building value.
      printf("%s^%s^%s^%s^%s^%s^%s^%s^%s^%s^%s^%s^%s\n", "YEAR", "SWIS", "TOWN", "ADDR", "ACCT", "PARCEL_ID", "LUC", "PARCEL_TYPE", "OWN1", "OWN2", "ACCR", "LAND_VAL", "FULL_MKT_VAL")}; 
  {
        ## The first field of the record is the header for all of the tax records on the "page".
        split($1, lns, "\n"             ); # Split the first field into lines.
        split(lns[4], tn, "\\(|\\)"     ); # Split the 4th line to get the town info.
        split(tn[1], sw, ": "           ); # Split the first part of the town info to get the SWIS. 
        gsub(/[ \t]+$/, "", sw[2]       ); # Get the SWIS data.

        ## Now proceed to process each of the parcels for this page.
        ## The parcel data are contained in the fields from 2 to NF-1. 
        ## The first field was the header we just processed; the last field consists of blank lines.
        ## NOTE 1: "fields" on a given line are separated by at least three spaces.
        ##        Within a "field" data is packaged together separated by two spaces.
        for (i=2;i < NF; ++i) {
          printf("%s^%s^%s", year, sw[2], tn[2]); # Print the year, SWIS and town information. 
          split($i, lns, "\n"           ); # Split the parcel info into lines. 

          split(lns[1], addrs, "   +"   ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
          ln=length(addrs);
		  if (length(addrs[ln-2]) == 0) {
			  printf("^%s", "BAD_RECORD");
		  } else {
          	  printf("^%s", addrs[ln-2] ); # Print the address.
		  }
          split(addrs[ln-1], acct, ": " );
	  	  gsub(/[ \t]+/, "", acct[2]    );
	  	  if (acct[2] ~ /^ *$/) {
	  	  	printf("^%s", "XXXXXXX"     );
	      } else {
      	    printf("^%s", acct[2]       ); # Print the parcel account id.
	      }
          split(lns[2], parcel, "   +"  ); # The second line has the parcel info. 
          split(parcel[2], pid, "  "    ); # Get the parcel ID.
          printf("^%s", pid[1]          ); # Print the parcel ID.
          split(parcel[3], LUC, " "     ); # Within a "field", data is separated by two spaces.
		  if (LUC[1] ~ /^[0-9]+$/) {
          	printf("^%s", LUC[1]        ); # If good, Print the LUC (land usage code) for this parcel type.
		  } else {
          	printf("^%s", "0"           ); # Else Print the LUC (land usage code) bad value.
		  }
          printf("^%s", parcel[3]       ); # Get and print the parcel type.  
          split(lns[3], info3, "   +"   ); # Get line 3 info.
          printf("^%s", info3[2]        ); # Print out the first owner.
          split(lns[4], own2, "   +"    ); # Get the second owner/address.
          split(own2[2], ow2, "  "      ); # Remove any extra characters.
          printf("^%s", ow2[1]          ); # Print out the second owner (could also be an address if no second owner).
          if (own2[3] ~ /ACREAGE/) {
            split(own2[3], acr, "  "    ); # Get the acreage info.
			if (acr[2] ~ /^[0-9.]+$/) {
				printf("^%s", acr[2]);
			} else {
      		  printf("^%s", "0"         ); # Print the parcel acreage.
		    }
          } else {
            split(lns[5], l6info, "   +"); # Get the sixth line as it may contain the acreage info.
            if (l6info[3] ~ /ACREAGE/) {
              split(l6info[3], acr, "  "); 
			  if (acr[2] ~ /^[0-9.]+$/) {
				printf("^%s", acr[2]);
			  } else {
      		    printf("^%s", "0"       ); # Print the parcel acreage.
		      }
		    } else {
      		    printf("^%s", "BAD_RECORD"); # Print the parcel acreage.
		    }
          } 
	      split(info3[4], lval, " "     ); # Extract the land assessed value...
	      gsub(/,/, "", lval[1]         );
		  if (lval[1] ~ /^[0-9,]+$/) {
			  gsub(/,/, "", lval[1]);
			  printf("^%s", lval[1]);
		  } else {
	      	printf("^%s", "0"        ); # Print the land assessed value.
		  }
          ## Now get the Full market value of the parcel.
          ## This can be in any one of the lines 5, 6, 7, or 8.
          mkt_pat = "FULL MKT VAL  ([0-9,]+)";
          if (match(lns[4], mkt_pat, m)) {
          } else if (match(lns[5], mkt_pat, m)) { 
          } else if (match(lns[6], mkt_pat, m)) {
          } else if (match(lns[7], mkt_pat, m)) { 
          } else {
             match(lns[8], mkt_pat, m    ); 
          }
		  gsub(/,/, "", m[1]);
		  if (m[1] ~ /^[0-9]+$/) {
			  printf("^%s", m[1]);
		  } else {
		  	printf("^%s", "-10000");
	      }
          printf("\n"                    ); # Close out this record.
        } 
  }

