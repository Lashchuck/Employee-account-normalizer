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

declare -A email_count  # Tablica do śledzenia unikalnych e-maili
declare -A name_count   # Tablica do zliczania nazw

temp_file=$(mktemp)

# Parsowanie CSV z obsługą przecinków w polach i cudzysłowów
awk -v OFS=',' '
  BEGIN { FS=OFS=","; FPAT="([^,]+)|(\"[^\"]+\")" }
  NR==1 { print; next }
  {
    gsub(/\r/, "");
    print
  }
' "$input_file" > "$temp_file"

# Pierwsze przejście: Zliczanie wystąpień nazw
while IFS=, read -r id location name title email department; do
  [[ "$id" == "id" ]] && continue
  first_name="${name%% *}"
  surname="${name##* }"
  formatted_name="${first_name:0:1}${surname,,}"
  name_count["$formatted_name"]=$((name_count["$formatted_name"] + 1))
done < "$temp_file"

# Drugie przejście: Generowanie wyniku
{
  read -r header
  printf "%s\n" "$header" > "$output_file"  # Zapis nagłówka

  while IFS=, read -r id location name title email department; do
    # Obsługa pola `title` z cudzysłowami i przecinkami
    if [[ "$title" == \"* && "$title" != *\" ]]; then
      while IFS=, read -r extra; do
        title="$title,$extra"  # Łączenie fragmentów pola `title`
        [[ "$title" == *\" ]] && break
      done
    fi

    # Formatowanie imienia i nazwiska
    first_name="${name%% *}"
    surname="${name##* }"
    formatted_name=$(format_name "$first_name" "$surname")

    # Generowanie unikalnego e-maila
    base_email="${first_name:0:1}${surname,,}"
    unique_email="${base_email,,}@abc.com"

    # Dodanie location_id w przypadku powtórzeń
    if [[ -n "${email_count["$unique_email"]}" || ${name_count["$base_email"]} -gt 1 ]]; then
      unique_email="${base_email,,}${location}@abc.com"
    fi

    # Śledzenie użycia e-maila
    email_count["$unique_email"]=1

    # Zapis do pliku wynikowego
    printf "%s,%s,%s,%s,%s,%s\n" \
      "$id" "$location" "$formatted_name" "$title" "$unique_email" "$department" >> "$output_file"
  done
} < "$temp_file"

rm -f "$temp_file"
printf "The script has finished processing. The file '%s' has been created.\n" "$output_file"
