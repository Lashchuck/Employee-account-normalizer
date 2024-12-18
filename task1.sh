#!/bin/bash

# Check if the file path is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 path_to_accounts.csv"
  exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file"
  exit 1
fi

# Function to format names and emails
format_name() {
  local name="$1"
  local surname="$2"
  local location_id="$3"

  # Capitalize the first letter of the name and surname, and lowercase the rest
  formatted_name="$(echo "$name" | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')"
  formatted_surname="$(echo "$surname" | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')"

  # Create the email
  formatted_email="${formatted_name:0:1}${formatted_surname}@abc.com"

  # Return formatted name, email, and location_id
  echo "$formatted_name,$formatted_email,$location_id"
}

# Read input file and process each line
while IFS=, read -r name surname email location_id
do
  # Skip the header line
  if [ "$name" == "name" ]; then
    continue
  fi

  # Get formatted name, email, and location_id
  result=$(format_name "$name" "$surname" "$location_id")
  echo "$result" >> "$output_file"
done < "$input_file"

echo "Updated accounts have been written to $output_file"