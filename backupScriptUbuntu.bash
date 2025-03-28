#!/bin/bash

# Name: Bencze Marton

# Check if two parameters were provided
if [ ! $# -eq 2 ]
then 
  echo usage: [time] [file]
  exit 1
fi

# Check if the second parameter is a file
if [ ! -f $2 ]
then 
  echo $2 is not a file
  echo usage: [time] [file]
  exit 1
fi

# Check if the first parameter is a positive integer or float
if ! [[ "$1" =~ ^[0-9]*\.?[0-9]+$ ]]
then 
  echo $1 is not a positive integer/float
  echo usage: [time] [file]
  exit 1
fi

filename=$2
interval=$1

declare -A map

for i in $(<$filename) # iterate word by word from the file
do 
  if [ ! -f $i ] # if the file does not exist, set its value to 0
  then
    map[$i]=0
  else
    map[$i]=`stat -c "%Y" $i` # store the last modification time
  fi
done

counter=0
while true
do
  for i in "${!map[@]}"
  do
    if [ ! ${map[$i]} -eq 0 ]
    then 
      mod=`stat -c "%Y" $i` # mod: stores the current modification time

      if [ ! ${map[$i]} -eq $mod ]
      then 
        if [ ! -f 1b.u.$i ]
        then 
          cp $i 1b.u.$i
        else
          if [ ! -f 2b.u.$i ]
          then
            cp $i 2b.u.$i
          else
            if [ ! -f 3b.u.$i ]
            then
              cp $i 3b.u.$i
            else
              cp 2b.u.$i 1b.u.$i # latest will always be in 3b
              cp 3b.u.$i 2b.u.$i
              cp $i 3b.u.$i
            fi
          fi
        fi
        map[$i]=$mod
        echo $i: a new backup has been created
      fi
    fi
  done

  sleep $interval
  ((counter++))

  if [ $counter -eq 10 ]
  then
    counter=0

    # Handle entries that were removed from the list
    for i in "${!map[@]}"
    do
      match=`grep -lwF $i $filename` # returns the name of the file if it exists in the list

      if [ ! -f 1b.u.$i ] # needed in case the file was never modified
      then
        map[$i]=0
      fi

      if [ ! ${map[$i]} -eq 0 ] && [ "$filename" != "$match" ]
      then
        echo "$i: file was removed from the list, do you want to restore the last backup? (yes/no)"
        read response

        if [ "$response" == "yes" ]
        then
          if [ -f 3b.u.$i ]
          then
            cp 3b.u.$i $i
            rm 3b.u.$i
            rm 2b.u.$i
            rm 1b.u.$i
          else
            if [ -f 2b.u.$i ]
            then
              cp 2b.u.$i $i
              rm 2b.u.$i
              rm 1b.u.$i
            else
              if [ -f 1b.u.$i ]
              then
                cp 1b.u.$i $i
                rm 1b.u.$i
              fi
            fi
          fi
        else
          if [ -f 3b.u.$i ]
          then
            rm 3b.u.$i
            rm 2b.u.$i
            rm 1b.u.$i
          else
            if [ -f 2b.u.$i ]
            then
              rm 2b.u.$i
              rm 1b.u.$i
            else
              if [ -f 1b.u.$i ]
              then
                rm 1b.u.$i
              fi
            fi
          fi
        fi

        map[$i]=0
      fi
    done

    # Now handle any newly added entries by re-reading the file
    for i in $(<$filename)
    do
      if [ ! -f $i ]
      then
        map[$i]=0
      else
        map[$i]=`stat -c "%Y" $i`
      fi
    done
  fi
done
