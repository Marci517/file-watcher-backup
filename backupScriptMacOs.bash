#!/opt/homebrew/bin/bash

# Name: Bencze Marton

# Check that exactly 2 parameters are provided
if [ "$#" -ne 2 ]; then 
  echo "Usage: [time_interval] [file_list]"
  exit 1
fi

# Check if the second parameter is a valid file
if [ ! -f "$2" ]; then 
  echo "$2 is not a valid file"
  echo "Usage: [time_interval] [file_list]"
  exit 1
fi

# Validate that the first parameter is a positive integer or float
if ! [[ "$1" =~ ^[0-9]*\.?[0-9]+$ ]]; then 
  echo "$1 is not a positive number"
  echo "Usage: [time_interval] [file_list]"
  exit 1
fi

file_list="$2"
interval="$1"
declare -A file_modtimes

# Initial read of the file list
while IFS= read -r file; do
  if [ ! -f "$file" ]; then
    file_modtimes["$file"]=0
  else
    file_modtimes["$file"]=$(stat -f "%m" "$file")
  fi
done < "$file_list"

counter=0

while true; do
  for file in "${!file_modtimes[@]}"; do
    if [[ "${file_modtimes[$file]}" =~ ^[0-9]+$ ]] && [ "${file_modtimes[$file]}" -ne 0 ]; then
      current_mod=$(stat -f "%m" "$file")

      if [ "${file_modtimes[$file]}" -ne "$current_mod" ]; then
        if [ ! -f "1b.u.$file" ]; then
          cp "$file" "1b.u.$file"
        elif [ ! -f "2b.u.$file" ]; then
          cp "$file" "2b.u.$file"
        elif [ ! -f "3b.u.$file" ]; then
          cp "$file" "3b.u.$file"
        else
          cp "2b.u.$file" "1b.u.$file"
          cp "3b.u.$file" "2b.u.$file"
          cp "$file" "3b.u.$file"
        fi

        file_modtimes["$file"]=$current_mod
        echo "$file: a new backup has been created"
      fi
    fi
  done

  sleep "$interval"
  ((counter++))

  if [ "$counter" -eq 10 ]; then
    counter=0

    # Handle removed entries
    for file in "${!file_modtimes[@]}"; do
      exists_in_list=$(grep -lwF "$file" "$file_list")

      if [ ! -f "1b.u.$file" ]; then
        file_modtimes["$file"]=0
      fi

      if [[ "${file_modtimes[$file]}" -ne 0 && "$file_list" != "$exists_in_list" ]]; then
        echo "$file has been removed from the list. Do you want to restore the latest backup? (yes/no)"
        read -r answer

        if [ "$answer" == "yes" ]; then
          if [ -f "3b.u.$file" ]; then
            cp "3b.u.$file" "$file"
            rm "3b.u.$file" "2b.u.$file" "1b.u.$file"
          elif [ -f "2b.u.$file" ]; then
            cp "2b.u.$file" "$file"
            rm "2b.u.$file" "1b.u.$file"
          elif [ -f "1b.u.$file" ]; then
            cp "1b.u.$file" "$file"
            rm "1b.u.$file"
          fi
        else
          rm -f "3b.u.$file" "2b.u.$file" "1b.u.$file"
        fi

        file_modtimes["$file"]=0
      fi
    done

    # Reload the file list for any new additions
    while IFS= read -r file; do
      if [ ! -f "$file" ]; then
        file_modtimes["$file"]=0
      else
        file_modtimes["$file"]=$(stat -f "%m" "$file")
      fi
    done < "$file_list"
  fi
done
