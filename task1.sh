#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage: ./task1.sh /path/to/accounts.csv"
    exit 0
fi

file=$1

# Exit if provided file doesn't exist
if [ ! -f $file ]
then
    echo "File $file doesn't exist"
    exit 1
fi

# Extract directory from file
path=$(dirname $file)

# Processing csv file with awk
awk -v FS="," -v OFS="," '
    # Skip first row, as it contains only column names
    NR == 1 { print; next }

    # First pass through file to check for uniqueness of emails
    NR == FNR {
        # 3rd field contains name
        # splitting name to first name and last name
        split($3, name, / /)
        email = tolower(substr(name[1], 1, 1) name[2])
        ++counter[email]
        next
    }

    # Second pass through file, skipping first line
    NR > FNR && FNR != 1 {
        # Create an array from fields as the default FS processes
        # quoted commas incorrectly
        j=0
        inside_quotes=0
        for(i=1; i<=NF; i++) {
            # Opening quote, save to new field,
            # set inside_quotes to true
            if($i ~ /^\"/) {
                inside_quotes=1
                j++
                fields[j] = $i
            }
            # Closing quote, append to last field, set inside_quote to false
            else if($i ~ /\"$/)  {
                inside_quotes=0
                fields[j] = fields[j] OFS $i
            }
            # middle of quoted text, append to last field
            else if (inside_quotes==1) {
                fields[j] = fields[j] OFS $i
            }
            # outside of quotes, save to new field
            else {
                j++
                fields[j] = $i
            }
        }
        # fields[3] contains name
        # Split name by space
        split(fields[3], name, / /)
        # Change the first character to uppercase, all other characters to lower case
        name[1] = toupper(substr(name[1], 1, 1)) tolower(substr(name[1], 2))
        # For the last name, split into two parts if it's a two-part name
        if (match(name[2], "-")) {
            split(name[2], lastname, "-")
            lastname[1] = toupper(substr(lastname[1], 1, 1)) tolower(substr(lastname[1], 2))
            lastname[2] = toupper(substr(lastname[2], 1, 1)) tolower(substr(lastname[2], 2))
            fields[3] = name[1] " " lastname[1] "-" lastname[2]
        } else {
            name[2] = toupper(substr(name[2], 1, 1)) tolower(substr(name[2], 2))
            fields[3] = name[1] " " name[2]
        }

        # email format: flast_name@abc.com
        email = tolower(substr(name[1], 1, 1) name[2])

        # if the email is not unique, append location id
        if (counter[email] > 1) email=email fields[2]
        fields[5] = email "@abc.com"

        # Set new values for all 6 columns
        NF=6
        for(i=1; i<=NF; i++) $i=fields[i]
        print
    }
' $file $file > $path/accounts_new.csv

echo "The script has finished processing. The file 'accounts_new.csv' has been created."
