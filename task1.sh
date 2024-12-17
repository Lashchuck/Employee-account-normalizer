#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 path_to_accounts_csv"
    exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

if [ ! -f "$input_file" ]; then
    echo "File not found!"
    exit 1
fi

> "$output_file"

while IFS=, read -r id location name role email
do
    first_name_initial=$(echo "$name" | awk '{print tolower(substr($1, 1, 1))}')
        last_name=$(echo "$name" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; printf "%s", $NF}')

        formatted_name=$(echo "$first_name_initial" | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')$(echo "$last_name" | awk '{print tolower($0)}')
        formatted_email="${formatted_name,,}@abc.com"

    echo "$id,$location,$formatted_name,$role,$formatted_email" >> "$output_file"
done < "$input_file"

echo "File '$output_file' created successfully."
