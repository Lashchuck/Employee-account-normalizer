#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage: ./task1.sh /path/to/accounts.csv"
    exit 0
fi

file=$1

if [ ! -f $file ]
then
    echo "File $file doesn't exist"
    exit 1
fi

path=$(dirname $file)

awk -v FS="," -v OFS="," '
    NR == 1 { print; next }

    NR == FNR {
        split($3, name, / /)
        email = tolower(substr(name[1], 1, 1) name[2])
        ++counter[email]
        next
    }

    NR > FNR && FNR != 1 {
        j=0
        inside_quotes=0
        for(i=1; i<=NF; i++) {
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
        name[2] = toupper(substr(name[2], 1, 1)) tolower(substr(name[2], 2))
        fields[3] = name[1] " " name[2]

        email = tolower(substr(name[1], 1, 1) name[2])

        if (counter[email] > 1) email=email fields[2]
        fields[5] = email "@abc.com"

        NF=6
        for(i=1; i<=NF; i++) $i=fields[i]
        print
    }
' $file $file > $path/accounts_new.csv

echo "The script has finished processing. The file 'accounts_new.csv' has been created."
