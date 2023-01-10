#!/bin/bash
set -ex -o pipefail


check_deps () {
    docker=$(which docker)
}


build_container () {
    $docker build --tag nicholasadamou-cv "$(pwd)"
}


format_cv () {
    $docker run --volume "$(pwd)":/data nicholasadamou-cv latexindent --silent --outputfile=cv.tex cv.tex
}


build_pdf () {
    $docker run --volume "$(pwd)":/data nicholasadamou-cv pdflatex cv.tex
}


build_html () {
    $docker run -ti --rm -v "$(pwd)":/pdf bwits/pdf2htmlex-alpine pdf2htmlEX --zoom 1.3 cv.pdf
}


check_deps
build_container
format_cv
build_pdf
build_html

mkdir -p docs
mv cv.pdf docs
mv cv.html docs/index.html
