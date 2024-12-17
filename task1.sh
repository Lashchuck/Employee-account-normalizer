#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 path/to/accounts.csv"
    exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

format_name() {
    echo "$1" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1'
}

generate_email() {
    local name="$1"
    local surname="$2"
    echo "${name:0:1}${surname,,}@abc.com"
}

while IFS=, read -r id location name position
do

    if [[ "$id" == "id" ]]; then
        continue
    fi

    first_name="${name%% *}"
    surname="${name##* }"

    formatted_name=$(format_name "$first_name $surname")
    email=$(generate_email "$first_name" "$surname")

    echo "$id,$location,$formatted_name,$position,$email" >> "$output_file"
done < "$input_file"
