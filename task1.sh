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

temp_file=$(mktemp)

# Poprawne przetwarzanie CSV z uwzględnieniem cudzysłowów i przecinków
awk -v OFS=',' '
  BEGIN { FPAT = "([^,]+)|(\"[^\"]+\")" }
  NR == 1 { print; next }                  # Przepisanie nagłówka
  {
    gsub(/\r/, "")                         # Usunięcie znaków powrotu karetki
    for (i = 1; i <= NF; i++) {
      gsub(/^"|"$/, "", $i)                # Usunięcie cudzysłowów otaczających
    }
    print
  }
' "$input_file" > "$temp_file"

# Pierwsze przejście: zliczanie wystąpień nazw
while IFS=, read -r id location name title email department; do
  [[ "$id" == "id" ]] && continue

  first_name="${name%% *}"
  surname="${name##* }"
  formatted_name="${first_name:0:1}${surname,,}"

  name_count["$formatted_name"]=$((name_count["$formatted_name"] + 1))
done < "$temp_file"

# Drugie przejście: generowanie wyniku
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

  # Właściwy format dla title i pozostałych pól
  printf "%s,%s,%s,\"%s\",%s,%s\n" \
    "$id" "$location" "$formatted_name" "$title" "$final_email" "$department" >> "$output_file"
done < "$temp_file"

rm -f "$temp_file"

printf "The script has finished processing. The file '%s' has been created.\n" "$output_file"