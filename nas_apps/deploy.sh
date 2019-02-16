#!/bin/bash

set -e

# Decrypt
gpg2 -d -o secrets secrets.gpg 

# Replace variables
while read -r line; do
  name=$(cut -d '=' -f1 <<< "${line}")
  value=$(cut -d '=' -f2- <<< "${line}")
  echo "var=|$name| and value=|$value|"
  #grep "<<$name>>" -R .
  find . -type f -print0 | xargs -0 sed -i "s|<<$name>>|$value|g"
done < secrets

git status

# Deploy
for dir in */; do
	cd "$dir"
	NAMESPACE="$(basename "$(pwd)")"
	docker-compose -p "${NAMESPACE}" up -d
	cd ../
done
