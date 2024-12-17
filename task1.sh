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

generate_email() {
  local name="$1"
  local surname="$2"
  local location_id="$3"
  local count="$4"

  # Generuj bazowy email bez location_id
  local formatted_name="${name:0:1}${surname,,}"

  # Dodaj location_id tylko jeśli dana osoba pojawia się więcej niż raz
  if [ "$count" -gt 1 ]; then
    echo "${formatted_name,,}${location_id}@abc.com"
  else
    echo "${formatted_name,,}@abc.com"
  fi
}

# Create or clear the output file
> "$output_file"

# Zlicz wystąpienia każdego imienia i nazwiska
declare -A name_count
while IFS=, read -r id location name title email department; do
  if [[ "$id" == "id" ]]; then
    continue
  fi

  full_name="${name,,}" # Klucz do sprawdzenia liczby wystąpień
  name_count["$full_name"]=$((name_count["$full_name"] + 1))
done < "$input_file"

# Przetwarzaj dane i generuj wyniki
while IFS=, read -r id location name title email department; do
  if [[ "$id" == "id" ]]; then
    echo "id,location,name,title,email,department" >> "$output_file"
    continue
  fi

  first_name="${name%% *}"
  surname="${name##* }"

  formatted_name=$(format_name "$first_name" "$surname")
  full_name="${name,,}"
  count=${name_count["$full_name"]}

  email=$(generate_email "$first_name" "$surname" "$location" "$count")

  echo "$id,$location,$formatted_name,$title,$email,$department" >> "$output_file"
done < "$input_file"
