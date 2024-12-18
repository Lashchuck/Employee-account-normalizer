# Employee account normalizer

Repository contains a Bash script designed to automate the normalization of employee account data. 

## Features
- **Name Normalization:** Converts the format of the name column.
- **Email Normalization:** Updates the email column to use the domain @abc and handles duplicate email cases by appending the location_id to make each email unique.
  
  Email format: first letter of the first name and the full last name in lowercase (e.g., jdoe@abc).
- **Output File:** Generates a new file, accounts_new.csv, with the standardized data.

## Usage
**Prerequisites:** 
- Bash shell environment.
- Ensure the input file accounts.csv exists and follows the required structure.
  
**Running the script:** 

```shell
./task1.sh path/to/accounts.csv
```

## Example:
### was:
```csv
2,1,Christina Gonzalez,Director,,
8,6,Bart charlow,Executive Director,,
9,7,Bart Charlow,Executive Director,,
```
### became:
```csv
2,1,Christina Gonzalez,Director,cgonzalez@abc.com,
8,6,Bart Charlow,Executive Director,bcharlow6@abc.com,
9,7,Bart Charlow,Executive Director,bcharlow7@abc.com,
```
