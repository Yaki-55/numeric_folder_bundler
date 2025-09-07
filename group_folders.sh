#!/bin/bash

# --- Argument Validation ---
# Ensures that the script receives exactly two arguments.
if [ "$#" -ne 2 ]; then
    echo "Error: Two arguments are required."
    echo "Usage: $0 <directory_path> <group_size>"
    exit 1
fi

# --- Variable Assignment ---
# Assigns arguments to descriptive variable names for better readability.
BASE_DIRECTORY=$1
GROUP_SIZE=$2

# --- Directory Verification ---
# Checks if the provided directory actually exists.
if [ ! -d "$BASE_DIRECTORY" ]; then
    echo "Error: The directory '$BASE_DIRECTORY' does not exist."
    exit 1
fi

echo "Analyzing directory: $BASE_DIRECTORY"
echo "Group size set to: $GROUP_SIZE"
echo "--------------------------------------------------"

# --- Determine the Folder Range ---
# Finds the highest-numbered folder to know the upper limit of the operation.
# `ls -v` lists contents sorted numerically (1, 2, ..., 10, 11 instead of 1, 10, 11, 2).
# `grep -E '^[0-9]+$'` ensures we only process names that are purely numeric.
# `tail -n 1` gets the last item in the list, which will be the highest number.
LAST_FOLDER=$(ls -v "$BASE_DIRECTORY" | grep -E '^[0-9]+$' | tail -n 1)

# If no numbered folders are found, inform the user and exit.
if [ -z "$LAST_FOLDER" ]; then
    echo "Warning: No numbered folders found to group in '$BASE_DIRECTORY'."
    exit 0
fi

echo "Highest numbered folder is: $LAST_FOLDER. Starting grouping process..."
echo ""

# --- Main Grouping Loop ---
# This loop iterates in increments of the group size (e.g., 1, 6, 11, ... if group size is 5).
for (( i=1; i<=LAST_FOLDER; i+=GROUP_SIZE )); do
    # Define the start of the range.
    range_start=$i
    
    # 1. The group name is calculated ALWAYS using the full group size.
    # Example: if i=101 and GROUP_SIZE=10, name_end will be 110.
    name_end=$((i + GROUP_SIZE - 1))
    GROUP_NAME="${range_start}-${name_end}"

    # 2. The ACTUAL end of the range is calculated to know which folders to move.
    # This is adjusted if it exceeds the last existing folder number.
    actual_end=$((i + GROUP_SIZE - 1))
    if [ "$actual_end" -gt "$LAST_FOLDER" ]; then
        actual_end=$LAST_FOLDER
    fi

    # Create the container folder with the full range name.
    echo "Creating group: $GROUP_NAME"
    GROUP_PATH="$BASE_DIRECTORY/$GROUP_NAME"
    mkdir "$GROUP_PATH"

    # --- Inner Loop for Moving Folders ---
    # Iterates using the actual end (up to the last folder that exists in that range).
    for (( j=range_start; j<=actual_end; j++ )); do
        SOURCE_FOLDER="$BASE_DIRECTORY/$j"
        # Move the folder only if it exists.
        if [ -d "$SOURCE_FOLDER" ]; then
            mv "$SOURCE_FOLDER" "$GROUP_PATH/"
            echo "  -> Moving '$j' to '$GROUP_NAME'"
        fi
    done
    echo "" # Adds a blank line for clearer output.
done

echo "Grouping process completed successfully!"