#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 patch/to/accounts.csv"
  exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

format_name() {
  local name="$1"
  local first_name="${name%%,*}"
  local surname="${name##*,}"

  # Format the first letter of the first name to uppercase and the rest to lowercase
  formatted_first_name=$(echo "${first_name:0:1}" | awk '{print tolower($0)}')$(echo "${first_name:1}" | awk '{print tolower($0)}')

  # Format the surname to lowercase
  formatted_surname=$(echo "$surname" | awk '{print tolower($0)}')

  echo "$formatted_first_name $formatted_surname"
}

# Function to generate email
generate_email() {
  local formatted_name="$1"
  local location_id="$2"

  # Use formatted first name initial and lowercase surname for the email
  echo "$(echo "${formatted_name,,}")${location_id}@abc.com"
}

# Create or clear the output file
> "$output_file"

while IFS=, read -r id location name title email department
do
  if [[ "$id" == "id" ]]; then
    continue
  fi

  # Extract first name and surname
  first_name="${name%% *}"
  surname="${name##* }"

  formatted_name=$(format_name "$first_name,$surname")
  email=$(generate_email "$first_name" "$surname" "$location")

  echo "$id,$location,$formatted_name,$title,$email,$department" >> "$output_file"
done < "$input_file"

echo "The script has finished processing. The accounts_new.csv file has been created."
