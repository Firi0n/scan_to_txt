# PDF to Text OCR Processor

A Bash script to extract text from specific chapters of a PDF file using OCR.
The script utilizes `qpdf`, `pdftoppm`, and `tesseract` to convert PDF pages to images and perform OCR, saving the text into organized chapter files.
The entire process is parallelized for maximum performance.

---

## 🚀 Features

- Extracts text from specific chapters or page ranges of a PDF file.
- Supports multiple languages through Tesseract.
- Efficient parallel processing for faster execution.
- Automatic cleanup of intermediate image files to save disk space.
- Comprehensive logging with timestamps and status messages.
- Handles invalid or empty images gracefully.

---

## 📝 Requirements

Make sure the following tools are installed on your system:

- **qpdf** - PDF manipulation and page extraction.
- **pdftoppm** (from **poppler-utils**) - Converts PDF pages to images.
- **tesseract** - OCR engine.
- **ImageMagick** (for `identify`) - Checks image validity.

### 🔧 Installation on Ubuntu

```bash
sudo apt update
sudo apt install qpdf poppler-utils tesseract-ocr imagemagick
```

---

## 💡 Usage

```bash
./script.sh <output_directory> <language> <input.pdf> <chapter_ranges>
```

### 🔑 Parameters

- **output_directory**: Directory where the extracted chapters will be saved.
- **language**: Language code for OCR (e.g., `eng`, `ita`, `deu`).
- **input.pdf**: Path to the input PDF file.
- **chapter_ranges**: One or more ranges of pages in the format `start:end`.

### 📝 Example

Extract chapters from a PDF book:

```bash
./script.sh chapters eng book.pdf 1:5 6:10 11:15
```

This will:

1. Create a folder named `chapters`.
2. Extract text from pages 1 to 5, 6 to 10, and 11 to 15.
3. Save the output as:
   - `chapters/chapter_1/chapter.txt`
   - `chapters/chapter_2/chapter.txt`
   - `chapters/chapter_3/chapter.txt`
4. Log details in:
   - `chapters/process.log`

---

## 📂 Output Structure

```
output_directory/
├── chapter_1/
│   ├── chapter.pdf
│   ├── chapter.txt
├── chapter_2/
│   ├── chapter.pdf
│   ├── chapter.txt
├── chapter_3/
│   ├── chapter.pdf
│   ├── chapter.txt
└── process.log
```

---

## 🌐 Language Support

Tesseract supports multiple languages. Check available languages with:

```bash
tesseract --list-langs
```

To install additional language packs on Ubuntu:

```bash
sudo apt install tesseract-ocr-ita tesseract-ocr-deu
```

To use multiple languages at once:

```bash
./script.sh chapters eng+ita book.pdf 1:5
```

---

## 📝 Log File

The script generates a log file (`process.log`) in the output directory, recording:

- Start and end times.
- Processed chapters and pages.
- Errors or warnings during the OCR process.

---

## 🧑‍💻 Contributing

Feel free to open issues or submit pull requests to improve the script.

---

## 📝 License

This project is licensed under the MIT License.
