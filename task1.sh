#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage: ./task1.sh /path/to/accounts.csv"
    exit 0
fi

file=$1

if [ ! -f "$file" ]
then
    echo "File $file doesn't exist"
    exit 1
fi

path=$(dirname "$file")

awk '
    BEGIN { FS=","; OFS=",";}

    NR == 1 {
        print
    }

    NR == FNR {
        split($3, name, / /)
        email = substr(name[1], 1, 1) name[2]
        email = tolower(email)
        ++counter[email]
    }

    NR > FNR && FNR != 1{

        j=0
        inside_quotes=0
        for(i=1;i<=NF;i++) {
            if($i ~ /^\"/) {
                inside_quotes=1
                j++
                fields[j] = $i
            }
            else if($i ~ /\"$/)  {
                inside_quotes=0
                fields[j] = fields[j] OFS $i
            }
            else if (inside_quotes==1) {
                fields[j] = fields[j] OFS $i
            }
            else {
                j++
                fields[j] = $i
            }
        }
        split(fields[3], name, / /)
        name[1] = toupper(substr(name[1], 1, 1)) tolower(substr(name[1], 2))

        split(name[2], parts, /-/)
        for (k in parts) {
            parts[k] = toupper(substr(parts[k], 1, 1)) tolower(substr(parts[k], 2))
        }
        name[2] = parts[1]
        for (k=2; k in parts; k++) {
            name[2] = name[2] "-" parts[k]
        }

        fields[3] = name[1] " " name[2]

        email = substr(name[1], 1, 1) name[2]
        gsub("-", "", email)
        email = tolower(email)

        if (counter[email] > 1) email=email fields[2]
        fields[5] = email "@abc.com"

        NF=6
        for(i=1;i<=NF;i++) $i=fields[i]
        print
    }
' "$file" "$file" > "$path/accounts_new.csv"

echo "The script has finished processing. The file 'accounts_new.csv' has been created."
