#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 accounts.csv"
    exit 1
fi

input_file=$1
output_file="accounts_new.csv"

# Function to format name and generate a unique email
generate_email() {
    local name="$1"
    local location_id="$2"

    # Format name
    formatted_name=$(echo "$name" | awk '{ for (i=1; i<=NF; i++) printf "%s%s", toupper(substr($i, 1, 1)), tolower(substr($i, 2)) }')

    # Generate unique email with location_id appended as suffix
    formatted_email=$(echo "$formatted_name" | awk -v loc_id="$location_id" '{ print tolower(substr($1, 1)) tolower($2) loc_id "@abc.com" }')

    echo "$formatted_name,$formatted_email"
}

# Read the input file line by line
while IFS=, read -r id location_id name department email; do
    # Format the name and generate a unique email
    formatted_data=$(generate_email "$name" "$location_id")

    # Write the formatted data to the output file
    echo "$id,$location_id,$formatted_data" >> "$output_file"
done < "$input_file"

echo "Updated accounts saved to $output_file"
