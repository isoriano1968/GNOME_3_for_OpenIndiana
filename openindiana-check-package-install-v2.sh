#!/bin/bash

# Initialize an associative array to store checked packages
declare -A checkedPackages

# Initialize an array to store packages that could not be installed
declare -a failedPackages

# Read the file line by line
while IFS= read -r line
do
  # Check if the line starts with "Searching for:"
  if [[ $line == "Searching for:"* ]]; then
    # Extract the package name
    package=${line#*: }

    # Check if the package has already been checked
    if [[ ${checkedPackages[$package]} ]]; then
      continue
    fi

    # Print the package name in bold
    echo -e "$(tput bold)Parsed package name: $package$(tput sgr0)"

    # Check if the package is installed
    if ! pkg info "$package" > /dev/null 2>&1; then
      # If not installed, try to install the package
      if ! pkg install "$package"; then
        # If installation fails, add the package to the failedPackages array
        failedPackages+=("$package")
      fi
    else
      # If installed, print the package info
      echo "Package info for $package:"
      pkg info "$package"
    fi

    # Mark the package as checked
    checkedPackages[$package]=1
  fi
done < "gnome-dependencies-check"

# Print the packages that could not be installed
if [ ${#failedPackages[@]} -ne 0 ]; then
  echo -e "\nPackages that could not be installed:"
  for package in "${failedPackages[@]}"; do
    echo "$package"
  done
fi
