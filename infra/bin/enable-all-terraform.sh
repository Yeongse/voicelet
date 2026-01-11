#!/bin/bash

set -eu

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC_DIR="$SCRIPT_DIR/src"
DEST_DIR="$PROJECT_ROOT/terraform"

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Source directory '$SRC_DIR' does not exist."
  exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
  echo "Error: Destination directory '$DEST_DIR' does not exist."
  exit 1
fi

echo "Copying files from bin/src/ to terraform/..."

# Find all files in bin/src and copy them to the corresponding location in terraform/
find "$SRC_DIR" -type f | while read -r src_file; do
  # Get the relative path from SRC_DIR
  relative_path="${src_file#$SRC_DIR/}"

  # Destination file path
  dest_file="$DEST_DIR/$relative_path"

  # Create destination directory if it doesn't exist
  dest_dir="$(dirname "$dest_file")"
  if [ ! -d "$dest_dir" ]; then
    mkdir -p "$dest_dir"
    echo "Created directory: $dest_dir"
  fi

  # Copy the file
  cp "$src_file" "$dest_file"
  echo "Copied: $relative_path"
done

echo "Done! All files from bin/src/ have been copied to terraform/."
