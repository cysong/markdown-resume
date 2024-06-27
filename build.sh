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
    echo "  clean          Remove the target directory and all its contents"
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

# Ensure target directory exists
ensure_target_dir() {
    if [ ! -d "target" ]; then
        mkdir target
    fi
}

# Convert Markdown to HTML
md2html() {
    local input_file="$1"
    local output_file="target/${2}.html"
	local title="${2}"
    ensure_target_dir
	cp ./resume-css-stylesheet.css ./target/
    pandoc -s -o "$output_file" -c resume-css-stylesheet.css --metadata title="$title" "$input_file"
}

# Convert HTML to PDF
html2pdf() {
    local input_file="$1"
    local output_file="target/${2}.pdf"
    ensure_target_dir
    wkhtmltopdf --enable-local-file-access "$input_file" "$output_file"
}

# Convert Markdown to DOCX
md2doc() {
    local input_file="$1"
    local output_file="target/${2}.docx"
    ensure_target_dir
    pandoc -o "$output_file" --reference-doc=resume-docx-reference.docx "$input_file"
}

# Convert Markdown to PDF (via HTML)
md2pdf() {
    local markdown_file="$1"
    local base_name="$2"
    md2html "$markdown_file" "$base_name"
    html2pdf "target/${base_name}.html" "$base_name"
}

# Clean target directory
clean_target() {
    rm -rf target
    echo "Cleaned target directory."
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
        check_file_exists "target/${base_name}.html"
        html2pdf "target/${base_name}.html" "$base_name"
        ;;
    md2doc)
        md2doc "$markdown_file" "$base_name"
        ;;
    md2pdf|""|" ")
        md2pdf "$markdown_file" "$base_name"
        ;;
    clean)
        clean_target
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
