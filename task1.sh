#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 patch/to/accounts.csv"
  exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

format_name() {
  echo "$1" | awk -F, '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1'
}

generate_email(){
  local name="$1"
  local surname="$2"
  local location_id="$3"
  local formatted_name="${name:0:1}${surname,,}"

    # Zmienia całą część imienia i nazwiska na małe litery
    echo "${formatted_name,,}${location_id}@abc.com"
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
