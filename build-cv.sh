#!/bin/bash
set -e -o pipefail

# Variables
http_server_pid=0
browser_sync_pid=0

# Functions
check_deps() {
    docker=$(which docker)
    if [ -z "$docker" ]; then
        echo "Docker not found! Please install it first."
        exit 1
    fi
}

build_container() {
    $docker build --tag nicholasadamou-cv "$(pwd)"
}

format_cv() {
    $docker run --volume "$(pwd)":/data nicholasadamou-cv latexindent --silent --outputfile=cv.tex cv.tex
}

build_pdf() {
    $docker run --volume "$(pwd)":/data nicholasadamou-cv pdflatex cv.tex
}

build_html() {
    $docker run -ti --rm -v "$(pwd)":/pdf bwits/pdf2htmlex-alpine pdf2htmlEX --zoom 1.3 cv.pdf
}

watch_and_recompile() {
    while true; do
        # Wait for changes in .tex files using fswatch
        fswatch -1 cv.tex

        # Re-run existing build functions
        format_cv
        build_pdf
        build_html

        # Move the new PDF and HTML to the docs folder
        mv cv.pdf docs
        mv cv.html docs/index.html
    done
}

check_and_kill_process() {
	port=$1

	# Check if any process is running on port $port
	if ! lsof -i:"$port" 2>/dev/null > /dev/null; then
		echo "No process is running on port $port"
		return
	fi

	if kill -9 "$(lsof -t -i:"$port" 2>/dev/null)" 2>/dev/null; then
		echo "Successfully killed the existing process running on port $port"
	else
		echo "Failed to kill the existing process running on port $port"
		exit 1
	fi
}

start_browser_sync() {
	# Check if npx is installed
	if ! npx --version 2>/dev/null > /dev/null; then
		echo "npx is not installed! Please install it first."
		exit 1
	fi

	# Check if any process is running on port 3000
	check_and_kill_process 3000

	# Start browser-sync
	npx browser-sync start --server --files "docs/*" --no-open --port 3000 &
	browser_sync_pid=$!
}

start_http_server() {
	# Check if any process is running on port 8080
	check_and_kill_process 8080

	python3 -m http.server 8080 --directory docs &
	http_server_pid=$!
}

cleanup() {
	# Kill the http server
	if [ $http_server_pid -ne 0 ]; then
		kill -9 $http_server_pid
	fi

	# Kill the browser-sync
	if [ $browser_sync_pid -ne 0 ]; then
		kill -9 $browser_sync_pid
	fi

    exit 0
}

main() {
    clear
    check_deps
    build_container
    format_cv
    build_pdf
    build_html

    mkdir -p docs
    mv cv.pdf docs
    mv cv.html docs/index.html

	start_http_server

	# TODO: Fix the following:
	# \! I can't write on file `cv.pdf'.
	# (Press Enter to retry, or Control-D to exit; default file extension is `.pdf')
	# Please type another file name for output:
	# \! Emergency stop.
	# \Hy@OutlineName ...utline goto name{#2}count#3{#4}
	# start_browser_sync

    # Trap the SIGINT signal (Ctrl+C) and call the cleanup function
    trap cleanup SIGINT

    watch_and_recompile
}

main
