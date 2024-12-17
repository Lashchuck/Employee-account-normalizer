#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 path/to/accounts.csv"
  exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

format_name() {
  local first_name="$1"
  local surname="$2"
  echo "${first_name^} ${surname^}"
}

generate_email() {
  local first_name="$1"
  local surname="$2"
  local location_id="$3"
  local count="$4"

  local formatted_email="${first_name:0:1}${surname,,}"
  if [ "$count" -gt 1 ]; then
    echo "${formatted_email,,}${location_id}@abc.com"
  else
    echo "${formatted_email,,}@abc.com"
  fi
}

> "$output_file"

declare -A name_count

temp_file=$(mktemp)
awk -F, '{
  gsub(/^"|"$/, "", $0);
  gsub(/,+$/, "", $0);
  print
}' "$input_file" > "$temp_file"

while IFS=, read -r id location name title email department; do
  if [[ "$id" == "id" ]]; then
    continue
  fi

  full_name="${name,,}"
  name_count["${first_name:0:1}${surname,,}"]=$((name_count["${first_name:0:1}${surname,,}"] + 1))
done < "$temp_file"

while IFS=, read -r id location name title email department; do
  if [[ "$id" == "id" ]]; then
    echo "$id,$location,$name,$title,$email,$department" >> "$output_file"
    continue
  fi

  first_name="${name%% *}"
  surname="${name##* }"

  formatted_name="${first_name:0:1}${surname,,}"
  count=${name_count["$formatted_name"]}
  full_name="${name,,}"

    final_email=$(generate_email "$first_name" "$surname" "$location" "$count")

    # Check if the email is a duplicate
    if [ "$count" -gt 1 ]; then
      # Add location_id to email if it's a duplicate
      echo "${final_email,,}${location_id}@abc.com"
    fi

    echo "$id,$location,$formatted_name,$title,$final_email,$department" >> "$output_file"
done < "$temp_file"

rm -f "$temp_file"

echo "The script has finished processing. The accounts_new.csv file has been created."