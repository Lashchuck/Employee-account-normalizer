#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 accounts.csv"
    exit 1
fi

input_file=$1
output_file="accounts_new.csv"

# Function to format name and email
format_name_email() {
    local name="$1"
    local email="$2"
    local location_id="$3"

    # Format name
    formatted_name=$(echo "$name" | awk '{ for (i=1; i<=NF; i++) printf "%s%s", toupper(substr($i, 1, 1)), tolower(substr($i, 2)) }')

    # Format email
    formatted_email=$(echo "$formatted_name" | awk '{ print tolower(substr($1, 1)) tolower($2) "@" "abc.com" }')

    # Combine formatted name, email and location_id
    echo "$formatted_name,$location_id,$formatted_email"
}

# Read the input file line by line
while IFS=, read -r id location_id name department email; do
    # Format the name and email
    formatted_data=$(format_name_email "$name" "$email" "$location_id")

    # Write the formatted data to the output file
    echo "$id,$formatted_data" >> "$output_file"
done < "$input_file"

echo "Updated accounts saved to $output_file"