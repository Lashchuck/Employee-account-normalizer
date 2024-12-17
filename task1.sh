#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 path/to/accounts.csv"
    exit 1
fi

# Ścieżka do pliku wejściowego
input_file="$1"
# Ścieżka do pliku wyjściowego
output_file="accounts_new.csv"

# Funkcja do formatowania imienia i nazwiska
format_name() {
    echo "$1" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1'
}

# Funkcja do generowania adresu e-mail
generate_email() {
    local name="$1"
    local surname="$2"
    # Tworzenie adresu e-mail w formacie: pierwsza litera imienia + pełne nazwisko, małymi literami
    echo "${name:0:1}${surname,,}@abc.com"
}

# Przetwarzanie pliku wejściowego
while IFS=, read -r id location name position
do
    # Pomijanie wiersza nagłówka
    if [[ "$id" == "id" ]]; then
        continue
    fi

    # Podział imienia i nazwiska
    first_name="${name%% *}"
    surname="${name##* }"

    # Formatuj imię i nazwisko oraz generuj adres e-mail
    formatted_name=$(format_name "$first_name $surname")
    email=$(generate_email "$first_name" "$surname")

    # Zapisz do pliku wyjściowego
    echo "$id,$location,$formatted_name,$position,$email" >> "$output_file"
done < "$input_file"

echo "Nowy plik z kontami został utworzony: $output_file"
