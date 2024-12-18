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
  local base_email="${first_name:0:1}${surname,,}"
  printf "%s@abc.com" "${base_email,,}${location_id}"
}

declare -A email_count

# Tworzenie nowego pliku wynikowego
{
  read -r header
  printf "%s\n" "$header"

  while IFS=, read -r id location_id name title email department; do
    # Obsługa pola `title` zawierającego przecinki
    while [[ "$title" != *\" && "$department" == "" ]]; do
      IFS=, read -r next_part
      title="$title,$next_part"
    done

    # Formatowanie nazwy
    first_name="${name%% *}"
    surname="${name##* }"
    formatted_name=$(format_name "$first_name" "$surname")

    # Generowanie e-maila
    unique_email=$(generate_email "$first_name" "$surname" "$location_id")

    # Jeśli e-mail już istnieje, dodaj `location_id` do nazwy użytkownika
    while [[ -n "${email_count["$unique_email"]}" ]]; do
      unique_email=$(generate_email "$first_name" "$surname" "${location_id}a")
    done

    email_count["$unique_email"]=1

    # Zapis do pliku wynikowego
    printf "%s,%s,%s,%s,%s,%s\n" \
      "$id" "$location_id" "$formatted_name" "$title" "$unique_email" "$department"
  done
} < <(awk -v OFS=',' '
  BEGIN { FS=OFS=","; FPAT="([^,]+)|(\"[^\"]+\")" }
  NR==1 { print; next }
  { gsub(/\r/, ""); print }
' "$input_file") > "$output_file"
printf "The script has finished processing. The file '%s' has been created.\n" "$output_file"
