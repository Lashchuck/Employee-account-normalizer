#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 path_to_accounts_csv"
    exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

# Sprawdzenie, czy plik wejściowy istnieje
if [ ! -f "$input_file" ]; then
    echo "File not found!"
    exit 1
fi

# Usuń istniejący plik wyjściowy, aby zapobiec powtórzeniom
> "$output_file"

# Przetworzenie pliku CSV
while IFS=, read -r id location name role email
do
    # Formatowanie nazwy (pierwsza litera wielka, reszta małe litery)
    formatted_name=$(echo "$name" | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')

    # Formatowanie emaila
    formatted_email="${formatted_name,,}@abc.com"

    # Zapisanie do pliku wyjściowego z odpowiednim separatorem
    echo "$id,$location,$formatted_name,$role,$formatted_email" >> "$output_file"
done < "$input_file"

echo "File '$output_file' created successfully."