#!/bin/bash

# --- Example Usage ---
# ./test.sh your_problem_folder
# ./test.sh your_problem_folder --keep-files
# ---------------------

# --- Argument Parsing ---
KEEP_FILES=false
PROBLEM_DIR=""
ORIGINAL_DIR=$(pwd) # Store the starting directory

# Loop through all provided arguments
for arg in "$@"; do
  case "$arg" in
    --keep-files)
      KEEP_FILES=true
      shift # Remove --keep-files from processing
      ;;
    *)
      # Assume the first non-flag argument is the directory
      if [ -z "$PROBLEM_DIR" ]; then
        PROBLEM_DIR=$arg
      fi
      ;;
  esac
done

# --- Initial Checks ---
# Check if a folder name was provided
if [ -z "$PROBLEM_DIR" ]; then
    echo "❌ Error: Please provide a folder name."
    echo "Usage: ./test.sh <path/to/problem_folder> [--keep-files]"
    exit 1
fi

# Check if the directory actually exists
if [ ! -d "$PROBLEM_DIR" ]; then
    echo "❌ Error: Directory '$PROBLEM_DIR' not found."
    # exit 1
fi

# Navigate into the problem directory
cd "$PROBLEM_DIR" || exit

# Check for required files
if [ ! -f "solution.cpp" ] || [ ! -f "tests.zip" ]; then
    echo "❌ Error: Make sure 'solution.cpp' and 'tests.zip' exist in '$PROBLEM_DIR'."
    cd "$ORIGINAL_DIR"
    exit 1
fi

# --- Setup and Compilation ---
# Unzip the test cases, -o overwrites existing files without asking
unzip -o tests.zip >/dev/null

# Check if unzip was successful
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to unzip 'tests.zip'."
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Remove the old binary before compiling a new one
rm -f solution

echo "Compiling solution.cpp... ⚙️"
g++ -std=c++17 -O2 -Wall solution.cpp -o solution

if [ $? -ne 0 ]; then
    echo "Compilation failed. ❌"
    cd "$ORIGINAL_DIR"
    exit 1
fi

echo "Compilation successful. Starting tests... 🚀"

# Remove any program output files from previous runs to ensure a clean slate
rm -f *.prog.out

# --- Testing Loop ---
# Loop through all input files (.in) in natural sort order (1, 2, 10...)
for in_file in $(ls -v *.in); do
    # Skip if no .in files are found
    [ -e "$in_file" ] || continue

    base=$(basename "$in_file" .in)
    ans_file="${base}.out"           # The correct answer file (from zip) is .out
    prog_out_file="${base}.prog.out" # Your program's output file

    # Get start time in nanoseconds
    start_time=$(date +%s%N)

    # Run the compiled solution with a 10-second timeout
    timeout 10s ./solution < "$in_file" > "$prog_out_file"
    status=$?

    # Get end time and calculate duration in milliseconds
    end_time=$(date +%s%N)
    duration_ns=$((end_time - start_time))
    duration_ms=$(( (end_time - start_time) / 1000000 ))
    duration_s=$(printf "%.2f" $(echo "$duration_ns / 1000000000" | bc -l))

    # Check the result
    if [ $status -eq 124 ]; then
        echo "Test case ${base}: Time Limit Exceeded ⏰ (~10000ms)"
    elif [ $status -ne 0 ]; then
        echo "Test case ${base}: Runtime Error 💥 (${duration_s}s)"
    # Check if a corresponding .out file exists before diffing
    elif [ ! -f "$ans_file" ]; then
        echo "Test case ${base}: Missing Answer File (.out) ❓"
    # Compare your program's output (.prog.out) with the correct answer (.out)
    elif diff -w "$prog_out_file" "$ans_file" >/dev/null; then
        echo "Test case ${base}: OK ✅ (${duration_s}s)"
    else
        echo "Test case ${base}: Wrong Answer ❌ (${duration_s}s)"
        if [ "$KEEP_FILES" = true ]; then
            diff -y -W 80 "$ans_file" "$prog_out_file"
        fi
    fi
done

# --- Cleanup ---
if [ "$KEEP_FILES" = false ]; then
    # Remove all generated and unzipped files by default
    rm -f *.in *.out *.prog.out solution
    cd "$ORIGINAL_DIR"
else
    # If --keep-files is used, just print a note. The binary is already kept.
    echo "Note: Test and output files have been kept as requested."
fi

echo "All tests finished. ✨"

# Go back to the parent directory

