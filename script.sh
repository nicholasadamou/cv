#!/bin/bash

# This script automates the process of building and updating a CV
# written in LaTeX. It watches for changes in the LaTeX file, rebuilds
# the PDF and HTML versions, and starts a live reload server for development.

# Trap interrupts and other exit scenarios and handle them gracefully
trap cleanup INT ERR EXIT

cleanup() {
    echo "Cleaning up..."

	# Clean up *.aux *.log *.out
    rm -f ./*.aux ./*.log ./*.out

    exit
}

build_pdf() {
	# Check if pdflatex is installed
	if ! command -v pdflatex &> /dev/null; then
		echo "Error: pdflatex is not installed."
		exit 1
	fi

	# Check if cv.tex exists. If not then exit
	if [ ! -e "cv.tex" ]; then
		echo "Error: cv.tex does not exist."
		exit 1
	fi

	# Compile cv.tex
    pdflatex cv.tex

    # Check if cv.pdf is created
    if [ ! -e "cv.pdf" ]; then
        echo "Error: Failed to create cv.pdf"
        exit 1
    fi

    echo "cv.pdf created successfully."

    # Clean up *.aux *.log *.out
    rm -f ./*.aux ./*.log ./*.out

	echo "Cleaned up auxiliary files."
}

format_pdf() {
	# Check if latexindent is installed
	if ! command -v latexindent &> /dev/null; then
		echo "Error: latexindent is not installed."
		exit 1
	fi

	# Check if cv.tex exists. If not then exit
	if [ ! -e "cv.tex" ]; then
		echo "Error: cv.tex does not exist."
		exit 1
	fi

	# Format cv.tex
	latexindent --silent --outputfile=cv.tex cv.tex

	# Check if cv.tex is created
	if [ ! -e "cv.tex" ]; then
		echo "Error: Failed to create cv.tex"
		exit 1
	fi

	echo "cv.tex formatted successfully."
}

build_html() {
	# Check if pdf2htmlEX is installed
	if ! command -v pdf2htmlEX &> /dev/null; then
		echo "Error: pdf2htmlEX is not installed."
		exit 1
	fi

    # Check if cv.pdf exists. If not then exit
    if [ ! -e "cv.pdf" ]; then
        echo "Error: cv.pdf does not exist."
        exit 1
    fi

	# Convert cv.pdf to cv.html
	pdf2htmlEX --zoom 1.3 cv.pdf

    # Check if cv.html is created
    if [ ! -e "cv.html" ]; then
        echo "Error: Failed to create cv.html"
        exit 1
    fi

    echo "cv.html created successfully."

    # Rename the output file to index.html for simpler routing
    mv cv.html index.html

	echo "Renamed cv.html to index.html."
}

build_cv() {
    echo "Building cv.pdf and cv.html..."

    build_pdf
    format_pdf
    build_html

    echo "Build completed."
}
get_checksum() {
    md5sum cv.tex | cut -d ' ' -f 1
}

watch_and_recompile() {
    echo "Monitoring cv.tex for changes..."

    # Get the initial checksum of the file
    last_checksum=$(get_checksum)

    while true; do
        # Sleep for a short period before checking again
        sleep 1

        current_checksum=$(get_checksum)
        if [ "$current_checksum" != "$last_checksum" ]; then
            echo "Content change detected. Recompiling..."

            if build_cv; then
                echo "Recompile successful."
            else
                echo "Recompile failed."
            fi

            # Update the last known checksum
            last_checksum=$current_checksum
        fi
    done
}

start_live_reload_server() {
    echo "Starting live reload server..."

	# Get the container's hostname
	hostname=$(hostname)

	# Start the live reload server
    browser-sync start --server --files "index.html" --no-open --port 3000 --host "$hostname"
}

# Run the build function once
build_cv

# Run the watch_and_recompile function in the background
watch_and_recompile &

# Run the start_live_reload_server function in the foreground
start_live_reload_server
