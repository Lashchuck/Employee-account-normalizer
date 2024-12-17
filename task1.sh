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
  echo "${first_name^} ${surname^}"  # Pierwsze litery dużymi
}

generate_email() {
  local first_name="$1"
  local surname="$2"
  local location_id="$3"
  local count="$4"

  # Wszystkie litery w emailu małe
  local formatted_email="${first_name:0:1}${surname,,}"
  if [ "$count" -gt 1 ]; then
    echo "${formatted_email,,}${location_id}@abc.com"
  else
    echo "${formatted_email,,}@abc.com"
  fi
}

# Tworzenie lub czyszczenie pliku wyjściowego
> "$output_file"

declare -A name_count

# Czyszczenie danych wejściowych
temp_file=$(mktemp)
awk -F, '{
  gsub(/^"|"$/, "", $0);  # Usuń cudzysłowy z początku i końca
  gsub(/,+$/, "", $0);   # Usuń nadmiarowe przecinki na końcu
  print
}' "$input_file" > "$temp_file"

# Pierwsza pętla do zliczania wystąpień imienia i nazwiska
while IFS=, read -r id location name title email department; do
  if [[ "$id" == "id" ]]; then
    continue
  fi

  full_name="${name,,}" # Klucz do sprawdzenia liczby wystąpień
  name_count["$full_name"]=$((name_count["$full_name"] + 1))
done < "$temp_file"

# Druga pętla do przetwarzania danych
while IFS=, read -r id location name title email department; do
  if [[ "$id" == "id" ]]; then
    echo "$id,$location,$name,$title,$email,$department" >> "$output_file"
    continue
  fi

  # Wyodrębnianie imienia i nazwiska
  first_name="${name%% *}"
  surname="${name##* }"

  # Formatowanie imienia i nazwiska
  formatted_name=$(format_name "$first_name" "$surname")
  full_name="${name,,}"
  count=${name_count["$full_name"]}

  # Generowanie emaila
  email=$(generate_email "$first_name" "$surname" "$location" "$count")

  # Zapis do pliku wyjściowego
  echo "$id,$location,$formatted_name,$title,$email,$department" >> "$output_file"
done < "$temp_file"

# Usuwanie pliku tymczasowego
rm -f "$temp_file"

echo "The script has finished processing. The accounts_new.csv file has been created."
