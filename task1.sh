#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 accounts.csv"
    exit 1
fi

input_file=$1
output_file="accounts_new.csv"

format_name_email() {
    local name="$1"
    local email="$2"
    local location_id="$3"

    formatted_name=$(echo "$name" | awk '{ for (i=1; i<=NF; i++) printf "%s%s", toupper(substr($i, 1, 1)), tolower(substr($i, 2)) }')

    formatted_email=$(echo "$formatted_name" | awk '{ print tolower(substr($1, 1)) tolower($2) "@" "abc.com" }')

    echo "$formatted_name,$location_id,$formatted_email"
}

while IFS=, read -r id location_id name department email; do

    formatted_data=$(format_name_email "$name" "$email" "$location_id")

    echo "$id,$formatted_data" >> "$output_file"
done < "$input_file"

echo "Updated accounts saved to $output_file"
