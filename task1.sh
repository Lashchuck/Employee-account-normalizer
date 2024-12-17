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

# Function to format name
format_name() {
  local name="$1"
  local first_name="${name%%,*}"
  local surname="${name##*,}"

  # Format the first letter of the first name to uppercase and the rest to lowercase
  formatted_name=$(echo "${first_name:0:1}" | awk '{print toupper($0)}')$(echo "${first_name:1}" | awk '{print tolower($0)}')

  # Format the surname to lowercase
  formatted_name+=" $(echo "$surname" | awk '{print tolower($0)}')"

  echo "$formatted_name"
}

# Function to generate email
generate_email() {
  local name="$1"
  local surname="$2"
  local location_id="$3"

  # Combine first letter of first name, lowercase surname, and location id
  echo "${name:0:1}${surname,,}${location_id}@abc.com"
}

# Create or clear the output file
> "$output_file"

while IFS=, read -r id location name title email department
do
  if [[ "$id" == "id" ]]; then
    continue
  fi

  # Extract first name and surname
  first_name="${name%%,*}"
  surname="${name##*,}"

  formatted_name=$(format_name "$first_name,$surname")
  email=$(generate_email "$first_name" "$surname" "$location")

  echo "$id,$location,$formatted_name,$title,$email,$department" >> "$output_file"
done < "$input_file"

echo "File '$output_file' created successfully."