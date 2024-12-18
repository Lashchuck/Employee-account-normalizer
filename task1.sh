#!/bin/bash

# Sprawdzanie czy skrypt otrzymał co najmniej jeden argument
if [ $# -lt 1 ]
then
    echo "Usage: ./task1.sh /path/to/accounts.csv"
    exit 0
fi

# Przypisanie pierwszego argumentu do zmiennej file
file=$1

# Weryfikacja czy podany plik istnieje
if [ ! -f "$file" ]
then
    echo "File $file doesn't exist"
    exit 1
fi

# Wyodrębnienie katalogu pliku wejściowego
path=$(dirname "$file")

# Przetwarzanie pliku CSV z awk
awk '
    BEGIN { FS=","; OFS=",";}

    # Pierwszy wiersz (nagłówek) - bez zmian
    NR == 1 {
        print
    }

    # Pierwsze przejście (liczenie prefiksów e-maili)
    NR == FNR {
        split($3, name, / /)
        email = substr(name[1], 1, 1) name[2]     # Generowanie prefiksu e-maila (pierwsza litera imienia + nazwisko)
        email = tolower(email)                    # Zamiana prefiksu e-maila na małe litery
        ++counter[email]                          # Zliczanie wystąpień każdego prefiksu e-maila
    }

    # Drugie przejście (przetwarzanie i generowanie nowych danych)
    NR > FNR && FNR != 1{

        j=0                                       # Zresetowanie licznika pól
        inside_quotes=0                           # Zresetowanie flagi wewnątrz cudzysłowów
        for(i=1;i<=NF;i++) {
            if($i ~ /^\"/) {                      # Pole zaczyna się od cudzysłowu
                inside_quotes=1
                j++
                fields[j] = $i
            }
            else if($i ~ /\"$/)  {                # Pole kończy się cudzysłowem
                inside_quotes=0
                fields[j] = fields[j] OFS $i
            }
            else if (inside_quotes==1) {          # Pole jest częścią ciągu w cudzysłowach
                fields[j] = fields[j] OFS $i
            }
            # outside of quotes, save to new field
            else {                                # Pole nie jest w cudzysłowach
                j++
                fields[j] = $i
            }
        }
        split(fields[3], name, / /)
        # Formatowanie imienia: pierwsza litera wielka, reszta małe
        name[1] = toupper(substr(name[1], 1, 1)) tolower(substr(name[1], 2))

        # Podzielenie nazwiska na części oddzielone myślnikiem
        split(name[2], parts, /-/)
        for (k in parts) {
            parts[k] = toupper(substr(parts[k], 1, 1)) tolower(substr(parts[k], 2))
        }
        # Łączenie części nazwiska z myślnikami
        name[2] = parts[1]
        for (k=2; k in parts; k++) {
            name[2] = name[2] "-" parts[k]
        }

        # Aktualizacja pola z imieniem i nazwiskiem
        fields[3] = name[1] " " name[2]

        # Generowanie adresu e-mail
        email = substr(name[1], 1, 1) name[2]    # Pierwsza litera imienia + nazwisko
        gsub(" ", "", email)                     # Usunięcie spacji
        email = tolower(email)                   # Zamiana na małe litery

        # Jeśli prefiks e-maila nie jest unikalny, dodaj identyfikator lokalizacji
        if (counter[email] > 1) email=email fields[2]
        fields[5] = email "@abc.com"            # Dodanie domeny do adresu e-mail

        NF=6
        # Aktualizacja pól w rekordzie
        for(i=1;i<=NF;i++) $i=fields[i]
        print
    }
' "$file" "$file" > "$path/accounts_new.csv"    # Przekierowanie wyjścia do nowego pliku CSV


echo "The script has finished processing. The file 'accounts_new.csv' has been created."
