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

declare -A name_count

temp_file=$(mktemp)

# Parsing CSV and writing to temporary file with full double quote and comma handling
awk -v OFS=',' '
  BEGIN { FS=OFS=","; FPAT="([^,]+)|(\"[^\"]+\")" }
  NR==1 { print; next }                        # Copy the header without changes
  {
    gsub(/\r/, "");                            # Remove carriage return characters
    for (i = 1; i <= NF; i++) {
      gsub(/^"|"$/, "", $i)                    # Remove surrounding quotes
    }
    print
  }
' "$input_file" > "$temp_file"

# First pass: count name occurrences
while IFS=, read -r id location name title email department; do
  [[ "$id" == "id" ]] && continue
  first_name="${name%% *}"
  surname="${name##* }"
  formatted_name="${first_name:0:1}${surname,,}"
  name_count["$formatted_name"]=$((name_count["$formatted_name"] + 1))
done < "$temp_file"

# Second pass: generate the result
{
  read -r header
  printf "%s\n" "$header" > "$output_file"  # Write header

  while IFS=, read -r id location name title email department; do
    first_name="${name%% *}"
    surname="${name##* }"
    formatted_name=$(format_name "$first_name" "$surname")
    count=${name_count["${first_name:0:1}${surname,,}"]}
    final_email=$(generate_email "$first_name" "$surname" "$location" "$count")

    # Correctly generating line with handling fields containing commas
    printf "%s,%s,%s,\"%s\",%s,%s\n" \
      "$id" "$location" "$formatted_name" "$title" "$final_email" "$department" >> "$output_file"
  done
} < "$temp_file"

rm -f "$temp_file"

printf "The script has finished processing. The file '%s' has been created.\n" "$output_file"