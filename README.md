# EmoSense

EmoSense is an innovative mobile application designed to enhance emotional well-being by using facial emotion detection to provide personalized music recommendations. The app integrates a reliable emotion detection model with a user-friendly interface, allowing users to track their emotions and receive tailored suggestions based on their mood.

## Features

- **Emotion Detection**: Utilizes advanced facial recognition technology to accurately identify a range of emotions.
- **Personalized Music Recommendations**: Suggests music based on the user's detected emotions and personal preferences.
- **Stress Monitoring**: Track stress levels and overlay stress trends with emotional states for better self-awareness.
- **Mood Analysis**: Provides graphs and insights into the user's emotional trends over time.
- **User-Friendly Interface**: Intuitive design with easy navigation for tracking and managing emotional states.
- **Daily Quotes**: Fetches motivational quotes daily to inspire users.
- **Stress Relief Content**: Access curated content such as yoga and meditation videos to help manage stress.

## Technologies Used

- **Flutter**: For building the cross-platform mobile application.
- **Dart**: The programming language used in the Flutter framework.
- **Camera Plugin**: For capturing images for emotion detection.
- **HTTP Requests**: For communicating with the server and retrieving data.
- **Firebase**: For storing user data and managing authentication.
- **Spotify API**: For fetching music genres and recommendations.
- **Python Flask**: For the backend server that processes emotion detection and handles requests.

## Getting Started

### Prerequisites

- Flutter SDK installed on your machine.
- Python and Flask installed for the backend.
- An IDE such as Android Studio or Visual Studio Code.
- Access to a local server for the emotion detection model.

### Setup Instructions

#### 1. Clone the Repository

```bash
git clone https://github.com/yjia28tan/EmoSense-Application.git
cd EmoSense-Application
```

#### 2. Flutter Setup
   ##### i. Install dependencies:
   ```bash
   flutter pub get
   ```
   
   ##### ii. Set up Firebase:
   - Configure Firebase for the app 
   - Add google-services.json (Android) or GoogleService-Info.plist (iOS)
   
   ##### iii. Run the app:
   ```bash
   flutter run
   ```

#### 3. Backend Setup
   ##### i. Navigate to the backend directory:
   ```bash
   cd backend
   ```

   #### ii. Download the FER model from Google Drive and place it to backend/model :
   ```https://drive.google.com/file/d/122epRv2JVvB4ziQtrn82qWKVhaHi3CNc/view?usp=sharing```
   
   ##### iii. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
   
   ##### iv. Run the Flask server:
   ```bash
   python emotion_detection_flask.py
   ```

#### 4. Emotion Detection Model
   - Ensure the emotion detection model is running (local or hosted).
   - Update API endpoints in Flutter app as needed.

## Usage
- **Onboarding**: The app will guide new users through an onboarding process, allowing them to select preferred music genres and artists for different emotions.
- **Emotion Detection**: After onboarding, users can detect their emotions via the app’s facial recognition feature and receive personalized music recommendations.
- **Stress Tracking**: The app allows users to log their stress levels and view trends over time.
- **Self-reflection**: Charts and graphs provide users with insights into their emotional and stress data for self-reflection.
