#!/bin/bash

CONFIG_FILE="afzc/nikgapps.config"
CONFIG_FOLDER="/afzc"
CONFIG="nikgapps.config"
PARAM_CONFIG="gapps.txt"
GAPPS_FILE=$(find . -name "NikGapps*" -printf "%f\n" | head -n 1)
UNZIPPED_GAPPS_FOLDER=$(basename -s .zip "$GAPPS_FILE") 

if [[ ! -f $PARAM_CONFIG ]]; then
  printf "Error: It doesn't exist $PARAM_CONFIG\n" 1>&2
  exit 1
fi

# Unzip .config file
unzip -jo "$GAPPS_FILE" "$CONFIG_FILE"

printf "Editing values of $PARAM_CONFIG...\n"
while IFS="=" read -r line; do
  # Ignore comments
  [[ $line =~ ^\s*\# ]] && continue

  # Split the line into key and value
  key=$(echo "$line" | cut -d '=' -f 1)
  value=$(echo "$line" | cut -d '=' -f 2-)

  # Ignore lines that don't have a key-value pair
  [[ -z $key || -z $value ]] && continue
  
  #config[$key]=$value
  printf "$key = $value\n"
  if grep -q "^$key=" "$CONFIG"; then
    sed -i "s|^$key=.*|$key=$value|" "$CONFIG"
  elif grep -q "^>>$key=" "$CONFIG"; then
    sed -i "s|^>>$key=.*|>>$key=$value|" "$CONFIG"
  fi
done < $PARAM_CONFIG

#Update the ZIP file with the edited nikgapps.config
unzip -o $GAPPS_FILE -d "$UNZIPPED_GAPPS_FOLDER"

cp "$CONFIG" "$UNZIPPED_GAPPS_FOLDER/$CONFIG_FOLDER"

cd "$UNZIPPED_GAPPS_FOLDER"
zip -ur ../"$GAPPS_FILE" *
cd ..

rm -rf "$UNZIPPED_GAPPS_FOLDER" 

rm "$CONFIG"
