# accountable

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Thai Banking E-Slip OCR Setup

This app includes functionality to scan Thai banking e-slips using Tesseract OCR. To use this feature:

1. Create an `assets/tessdata` directory in the project root
2. Download the Thai language traineddata file:
   - Download `tha.traineddata` and `eng.traineddata` from [Tesseract GitHub](https://github.com/tesseract-ocr/tessdata)
   - Place these files in the `assets/tessdata` directory
3. Make sure you've included the assets in pubspec.yaml
4. Install the app and test with Thai banking e-slips

Note: The Thai OCR works best on clear, well-lit images with standard Thai banking formats.
