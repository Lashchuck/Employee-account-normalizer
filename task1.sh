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

# Poprawione parsowanie CSV z usuwaniem cudzysłowów w kolumnie `title`
awk -v OFS=',' '
  BEGIN { FS=OFS="," }
  NR==1 { print; next }                        # Przepisz nagłówek bez zmian
  {
    line = $0                                  # Pobierz cały wiersz
    if (line ~ /".*,.*"/) {                    # Jeśli są przecinki w cudzysłowach
      while (line !~ /".*".*$/) {              # Dopóki wiersz nie jest kompletny
        getline next_line                      # Pobierz kolejny wiersz
        line = line next_line                  # Scal wiersze
      }
    }
    gsub(/"/, "", line)                        # Usuń wszystkie cudzysłowy
    print line                                 # Wydrukuj kompletny wiersz
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

    # Poprawne formatowanie wyjścia
    printf "%s,%s,%s,%s,%s,%s\n" \
      "$id" "$location" "$formatted_name" "$title" "$email" "$department" >> "$output_file"
  done
} < "$temp_file"

rm -f "$temp_file"
printf "The script has finished processing. The file '%s' has been created.\n" "$output_file"
