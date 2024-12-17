#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: ./task1.sh accounts.csv"
  exit 1
fi

input_file="$1"
output_file="accounts_new.csv"

# Process each line in the input file
awk -F, -v OFS=, '
BEGIN {
  print "ID,Location,Name,Role,Email"
}
{
  # Capitalize first letter of name/surname and lowercase the rest
  name = toupper(substr($3,1,1)) tolower(substr($3,2)) " " toupper(substr($4,1,1)) tolower(substr($4,2))

  # Update email format
  email = tolower(substr($3,1,1)) tolower(substr($4)) "@" "abc.com"

  # Include location_id in the email
  split($1, id_parts, "-")
  location_id = id_parts[2]
  email = email location_id

  # Print the updated line to the new file
  print $1, $2, name, $4, email
}
' "$input_file" > "$output_file"

echo "Updated file saved as $output_file"
