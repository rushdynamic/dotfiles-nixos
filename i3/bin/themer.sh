#!/usr/bin/env bash
# Usage: source this_script.sh colors.conf

CONF_FILE="$1"

while IFS='=' read -r key value; do
  # skip empty lines or comments
  [[ -z "$key" || "$key" == \#* ]] && continue
  
  # turn dashes into underscores for valid variable names
  varname=$(echo "$key" | tr '-' '_')
  
  # export the variable
  export "$varname=$value"
done < "$CONF_FILE"
