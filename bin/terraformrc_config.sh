#!/bin/bash

file="$HOME/.terraformrc"
default_content='credentials "app.terraform.io" {
  token = "REPLACE_ME"
}'

# Function to replace token
update_token() {
    echo "Existing token configuration found."
    read -p "Enter new token: " new_token

    if [[ -z "$new_token" ]]; then
        echo "No token entered. Aborting update."
        return 1
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS requires an empty string as an argument to -i
      sed -i '' "s/token = \".*\"/token = \"$new_token\"/" "$file"
    else
      # Linux does not require an empty string
      sed -i "s/token = \".*\"/token = \"$new_token\"/" "$file"
    fi
    echo "Token updated."
}

# Create the file with default content if it does not exist
if [ ! -f "$file" ]; then
    echo "File does not exist. Creating file with default settings..."
    echo "$default_content" > "$file"
fi

# Check if file exists and has read/write permissions to update the token value
if [ -f "$file" ]; then
    if [ -r "$file" ] && [ -w "$file" ]; then
        if grep -q 'credentials "app.terraform.io"' $file; then
            update_token
        else
            echo "No existing 'app.terraform.io' credentials found."
        fi
    else
        echo "$file does not have proper read/write permissions."
    fi
fi
