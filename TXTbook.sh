#!/bin/bash

# Check if sufficient arguments are provided
if [ $# -lt 4 ]; then
    echo "Usage: $0 output_directory language input.pdf chapters"
    echo "Example: $0 chapters eng book.pdf 1:5 6:10 11:15"
    exit 1
fi

# Output directory and language
output_dir="$1"
language="$2"
input_pdf="$3"

# Check if required commands are installed
for cmd in qpdf pdftoppm tesseract identify; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: Command '$cmd' not found."
        exit 1
    fi
done

# Create the output directory
mkdir -p "$output_dir"
log_file="$output_dir/process.log"
echo "🚀 Starting process at $(date)" > "$log_file"

# Chapter counter
chapter_number=1

# Iterate over chapter ranges passed as arguments
for range in "${@:4}"; do
    (
        start_page=${range%:*}
        end_page=${range#*:}
        
        chapter_dir="$output_dir/chapter_$chapter_number"
        mkdir -p "$chapter_dir"
        echo "📝 Processing chapter $chapter_number (pages $start_page-$end_page)..." | tee -a "$log_file"
        chapter_start=$(date +%s)

        # Extract pages with qpdf
        qpdf "$input_pdf" --pages . "$start_page"-"$end_page" -- "$chapter_dir/chapter.pdf"

        # Calculate the total number of pages to process
        total_pages=$((end_page - start_page + 1))
        
        # Iterate over each page in the extracted PDF
        for ((page_number=1; page_number<=total_pages; page_number++)); do
            echo "- Processing page: $page_number/$total_pages" | tee -a "$log_file"
            # Convert the specific page to an image
            pdftoppm -f "$page_number" -l "$page_number" -singlefile "$chapter_dir/chapter.pdf" "$chapter_dir/page" -png
            
            # Check if the image exists and is not empty
            if [ -s "$chapter_dir/page.png" ]; then
                dimensions=$(identify -format "%wx%h" "$chapter_dir/page.png" 2>/dev/null)
                if [ "$dimensions" != "0x0" ]; then
                    # Perform OCR on the generated image and append to the chapter text file
                    tesseract "$chapter_dir/page.png" stdout -l "$language" 2>>"$log_file" >> "$chapter_dir/chapter.txt"
                    echo "✅ Completed page $page_number" | tee -a "$log_file"
                else
                    echo "⚠️ Skipping invalid image (0x0): $chapter_dir/page.png" | tee -a "$log_file"
                fi
                # Remove the processed image to save space
                rm -f "$chapter_dir/page.png"
            else
                echo "⚠️ Skipping empty or non-existent image: $chapter_dir/page.png" | tee -a "$log_file"
            fi
        done
        
        chapter_end=$(date +%s)
        chapter_duration=$((chapter_end - chapter_start))
        echo "✅ Chapter $chapter_number completed in $chapter_duration seconds!" | tee -a "$log_file"
    ) &  # Run the entire chapter processing in the background
    
    ((chapter_number++))
done

# Wait for all background processes to complete
wait

echo "🚀 All chapters processed in parallel! Results are in '$output_dir'." | tee -a "$log_file"
echo "🎉 Process completed at $(date)" | tee -a "$log_file"
