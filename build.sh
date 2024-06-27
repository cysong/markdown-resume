#!/bin/bash

# Show help message
show_help() {
    echo "Usage: build.sh [option] [markdown_file]"
    echo ""
    echo "Options:"
    echo "  md2html        Convert Markdown to HTML"
    echo "  html2pdf       Convert HTML to PDF"
    echo "  md2doc         Convert Markdown to DOCX"
    echo "  md2pdf         Convert Markdown to PDF (via HTML)"
    echo "  help           Show this help message"
    echo ""
    echo "If no option is provided, 'md2pdf' will be executed by default."
    echo "If no markdown_file is provided, 'resume.md' will be used as the default."
}

# Get the filename without extension
get_filename_without_extension() {
    echo "$(basename -- "$1" | cut -d. -f1)"
}

# Check if input file exists
check_file_exists() {
    if [ ! -f "$1" ]; then
        echo "Error: File '$1' not found!"
        exit 1
    fi
}

# Convert Markdown to HTML
md2html() {
    local input_file="$1"
    local output_file="${2}.html"
    pandoc -s -o "$output_file" -c resume-css-stylesheet.css "$input_file"
}

# Convert HTML to PDF
html2pdf() {
    local input_file="$1"
    local output_file="${2}.pdf"
    wkhtmltopdf --enable-local-file-access "$input_file" "$output_file"
}

# Convert Markdown to DOCX
md2doc() {
    local input_file="$1"
    local output_file="${2}.docx"
    pandoc -o "$output_file" --reference-doc=resume-docx-reference.docx "$input_file"
}

# Convert Markdown to PDF (via HTML)
md2pdf() {
    local markdown_file="$1"
    local base_name="$2"
    md2html "$markdown_file" "$base_name"
    html2pdf "${base_name}.html" "$base_name"
}

# Main logic
option="$1"
markdown_file="${2:-resume.md}"
base_name=$(get_filename_without_extension "$markdown_file")

# Check if markdown file exists
check_file_exists "$markdown_file"

case "$option" in
    md2html)
        md2html "$markdown_file" "$base_name"
        ;;
    html2pdf)
        check_file_exists "${base_name}.html"
        html2pdf "${base_name}.html" "$base_name"
        ;;
    md2doc)
        md2doc "$markdown_file" "$base_name"
        ;;
    md2pdf|""|" ")
        md2pdf "$markdown_file" "$base_name"
        ;;
    help)
        show_help
        ;;
    *)
        echo "Invalid option: $option"
        show_help
        exit 1
        ;;
esac
