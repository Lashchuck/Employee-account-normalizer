#!/bin/bash

if [ -z "$1" ]; then
  printf "Usage: %s path/to/accounts.csv\n" "$0" >&2
  exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

format_name() {
  local first_name="$1"
  local surname="$2"
  printf "%s %s" "${first_name^}" "${surname^}"
}

generate_email() {
  local first_name="$1"
  local surname="$2"
  local location_id="$3"
  local count="$4"

  local formatted_email="${first_name:0:1}${surname,,}"
  if [[ "$count" -gt 1 ]]; then
    printf "%s%s@abc.com" "${formatted_email,,}" "${location_id}"
  else
    printf "%s@abc.com" "${formatted_email,,}"
  fi
}

> "$output_file"

declare -A name_count

# Temp file to clean and parse CSV properly
temp_file=$(mktemp)

# Convert CSV to correctly handle fields with quotes and commas
awk -v OFS=',' '
  BEGIN { FPAT = "([^,]+)|(\"[^\"]+\")" }  # Split fields correctly with quotes
  NR==1 { print; next }                  # Print header as is
  {
    gsub(/\r/, "")                      # Remove carriage returns
    for (i = 1; i <= NF; i++) {
      gsub(/^"|"$/, "", $i)             # Remove surrounding quotes
    }
    print
  }
' "$input_file" > "$temp_file"

# First pass: Count name occurrences
while IFS=, read -r id location name title email department; do
  [[ "$id" == "id" ]] && continue

  first_name="${name%% *}"
  surname="${name##* }"
  formatted_name="${first_name:0:1}${surname,,}"

  name_count["$formatted_name"]=$((name_count["$formatted_name"] + 1))
done < "$temp_file"

# Second pass: Process and generate the output CSV
while IFS=, read -r id location name title email department; do
  if [[ "$id" == "id" ]]; then
    printf "%s,%s,%s,%s,%s,%s\n" "$id" "$location" "$name" "$title" "$email" "$department" >> "$output_file"
    continue
  fi

  first_name="${name%% *}"
  surname="${name##* }"

  formatted_name=$(format_name "$first_name" "$surname")
  count=${name_count["${first_name:0:1}${surname,,}"]}

  final_email=$(generate_email "$first_name" "$surname" "$location" "$count")

  # Handle complex 'title' and 'department' fields with proper quotes
  printf "%s,%s,%s,\"%s\",%s,%s\n" \
    "$id" "$location" "$formatted_name" "$title" "$final_email" "$department" >> "$output_file"
done < "$temp_file"

rm -f "$temp_file"

printf "The script has finished processing. The %s file has been created.\n" "$output_file"