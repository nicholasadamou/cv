#!/bin/bash

build_pdf() {
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

build_html() {
    # Check if cv.pdf exists. If not then exit
    if [ ! -e "cv.pdf" ]; then
        echo "Error: cv.pdf does not exist."
        exit 1
    fi

	# Check if pdf2htmlEX is installed
	if ! command -v pdf2htmlEX &> /dev/null; then
		echo "Error: pdf2htmlEX is not installed."
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

# TODO - Does not appear to see changes made to cv.tex

watch_and_recompile() {
    echo "Monitoring cv.tex for changes..."

    while inotifywait -e modify cv.tex; do
        echo "Change detected. Recompiling..."

        if build_pdf && build_html; then
            echo "Recompile successful."
        else
            echo "Recompile failed."
        fi

        echo "Resuming monitoring..."
    done
}

echo "Building cv.pdf and cv.html..."

# Run the build functions once
build_pdf
build_html

# Run the watch_and_recompile function in the background
watch_and_recompile &

echo "Starting live reload server..."

# Get the container's hostname
hostname=$(hostname)

# Start the live reload server
browser-sync start --server --files "index.html" --no-open --port 3000 --host "$hostname"
