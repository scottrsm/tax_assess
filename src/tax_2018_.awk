
#### DESCRIPTION: This awk script first writes out a header line of the resulting pipe separated file.
####              It also sets up the record and field separators used to process the lower-hud (NY) tax data files
####              from 2012 to 2017, inclusive. It appears the tax data for these years is a pdf report that -- after text scraping --
####              appears to be broken into "pages" using a form-feed character, '\f'. The fields of such a record 
####              can now be thought of as beginning after the lines that look like: *******<PARCEL-ID>*******
####              The parcel info now can be split into lines and further processed to extract the information 
####              for a given parcel. Unfortunately the information format is inconsistent and we have to search over 
####              several lines for some of the pieces of data.
####
BEGIN{RS="\\f"     ; 
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
    split($1, lns, "\n"       ); # Split first parcel block into lines.
    split(lns[4], hl4, "   +" ); # Split the 4th line of the first (header) record to get the town info.
	split(hl4[1], tn, " "     );

	## NOTE: If there is no LAND VALUE, we set it to 0.
	
	# Process the rest of the "fields" after the "record" field.
    for (i=2;i <= NF; ++i) {
      printf("%s^%s^%s", year, tn[2], tn[3]); # Print the year, SWIS and town information.
      split($i    , lns  , "\n"     ); # Split the parcel (block of lines between the ****<PARCEL-ID>******) info into lines. 
      split(lns[5], addrs, "   +"   ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
	  if (length(addrs[1]) == 0) {
		  printf("^s", "BAD_RECORD");
	  } else {
          printf("^%s", addrs[1]    ); # Print the address.
	  }
      split(lns[1], acct , "   +"   ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
	  gsub(/ /, "", acct[4]         );
	  if (acct[4] ~ /^[ \t]*$/) {
	  	printf("^%s", "XXXXXXX"     );
	  } else {
      	printf("^%s", acct[4]       ); # Print the parcel account id.
	  }
      split(lns[2], pid  , "   +"   ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
      printf("^%s", pid[1]          ); # Print the parcel ID.
      split(pid[2], luc  , " "      ); # Extract LUC. 
	  if (luc[1] ~ /^[0-9]+$/) {
       	printf("^%s", luc[1]        ); # If good, Print the LUC (land usage code) for this parcel type.
	  } else {
       	printf("^%s", "0"           ); # Else Print the LUC (land usage code) bad value.
	  }
      printf("^%s", pid[2]          ); # Print the parcel type.
      split(lns[3], ln3  , "   +"   ); # Get the line 3 info.
      printf("^%s", ln3[1]          ); # Print Owner 1.
	  split(lns[4], ln4  , "   +"   ); # Get the line 4 info.
      printf("^%s", ln4[1]          ); # Print Owner 2.
      split(ln4[2], accr , " "      ); # Get the acreage.
	  if (accr[2] ~ /^[0-9.]+$/) {
      	printf("^%s", accr[2]       ); # Print the parcel acreage.
  	  } else {
      	printf("^%s", "0"           ); # Print the parcel acreage.
      }
	  split(ln3[3], lval , " "      ); # Extract the land (assessed) value...
	  if (lval[1] ~ /^[0-9,]+$/) {
	  	gsub(/,/, "", lval[1]       );
	  	printf("^%s", lval[1]       ); # Print the land value.
	  } else {
	  	printf("^%s", "0"           ); # Otherwise, there was no value -- set it to 0.
	  }
      if (lns[8] ~ /FULL MKT VAL/) {
        split(lns[8], fmktv, "   +" ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
        gsub(/,/, "", fmktv[3]      ); # Remove "," from (potential) full market value. 
		if (fmktv[3] ~ /^[0-9]+$/) {
        	printf("^%s", fmktv[3]  ); # Print the Full Market Value.
		} else {
			printf("^%s", "-10000"   );
		}
      } else {
        split(lns[9], fmktv, "   +" ); # Get the address of the parcel "fields" on a line are separated by at least three spaces.
       	gsub(/,/, "", fmktv[3]      ); # Remove "," from (potential) Full Assessment Value. 
		if (fmktv[3] ~ /^[0-9]+$/) {
			printf("^%s", fmktv[3]  ); # Print the Full Assessment Value, if it exists.
		} else {
        	printf("^%s", "-20000"   ); # Print 0 for the Full Assessment Value.
		}
      }

      printf("\n"                   ); # Close out this record. 

    }
 }
