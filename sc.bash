# --------------------
# sc.bash
# 03.25.26.
# --------------------
# Please, constract <bash> shell code for searching for pattern (provided as a parameter) of the given list of Git downloaded  code basises (keep the list of URLs in the internal array)
# and have a loop through this array.
# For each Git code basis print pathes to the files, which have a match.
# For each Git code basis print  number of unique files, which have a match.
# --------------------


#!/bin/bash

# Check if a search pattern was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <search_pattern>"
    exit 1
fi

PATTERN="$1"

# Internal list of Git repository URLs

# REPOS=(
#     "https://github.com/user/repo1.git"
#     "https://github.com/user/repo2.git"
#     "https://github.com/user/repo3.git"
# )

REPOS=(
	"https://github.com/idubinsky9/test_1.git"
)


# Create a temporary directory for clones
TEMP_DIR=$(mktemp -d)
echo "Working in temporary directory: $TEMP_DIR"
echo "------------------------------------------"

for REPO_URL in "${REPOS[@]}"; do
    # Extract repo name for display
    REPO_NAME=$(basename "$REPO_URL" .git)
    
    echo "Processing Repository: $REPO_NAME"
    
    # Clone the repo (depth 1 is faster for just searching)
    git clone --depth 1 -q "$REPO_URL" "$TEMP_DIR/$REPO_NAME"
    
    # Enter the repo directory
    pushd "$TEMP_DIR/$REPO_NAME" > /dev/null
    
    echo "Matching files:"
    # -r: recursive, -l: list filenames only
    # We store the results in a variable to avoid running grep twice
    MATCHES=$(grep -rl "$PATTERN" .)
    
    if [ -n "$MATCHES" ]; then
        echo "$MATCHES"
        
        # Count unique files
        # (grep -l already ensures unique filenames, but wc -l counts them)
        COUNT=$(echo "$MATCHES" | wc -l)
        echo "Total unique files with matches: $COUNT"
    else
        echo "No matches found."
        echo "Total unique files with matches: 0"
    fi
    
    # Move back and clean up the clone to save disk space
    popd > /dev/null
    rm -rf "$TEMP_DIR/$REPO_NAME"
    
    echo "------------------------------------------"
done

# Final cleanup
rm -rf "$TEMP_DIR"
echo "Done."