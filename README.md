# InkSight

InkSight is a mobile application that analyzes handwriting using AI to provide insights about personality traits, legibility, and emotional state.

## Features

- Capture photos of handwriting directly from the camera
- Upload existing handwriting images from the gallery
- Crop and edit images before analysis
- AI-powered handwriting analysis using Google's Gemini API
- Detailed analysis results with personality traits, legibility assessment, and emotional state detection
- Save analysis history for future reference

## Getting Started

### Prerequisites

- Flutter SDK (3.6.1 or higher)
- Dart SDK (3.6.1 or higher)
- Android Studio / Xcode for mobile development
- A Gemini API key from Google AI Studio

### Installation

1. Clone the repository
2. Create a `.env` file in the root directory with the following content:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   CUSTOM_API_URL=https://api.example.com/handwriting-analysis
   ```
3. Run `flutter pub get` to install dependencies
4. Run the app using `flutter run`

## How It Works

1. The user captures or uploads an image of handwriting
2. The image is sent to the Gemini API for analysis
3. The API returns insights about personality traits, legibility, and emotional state
4. The results are displayed in a user-friendly format

## Future Plans

See the [roadmap.md](roadmap.md) file for planned features and monetization strategies.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
