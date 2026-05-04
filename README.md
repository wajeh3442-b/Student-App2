# Quiz App (Flutter)

## 📱 Overview

This is a simple and interactive Quiz Application built using Flutter. The app presents multiple-choice questions with a timer, tracks the user's score, and stores the highest score locally using SharedPreferences.

---

## ✨ Features

* 🧠 Multiple-choice quiz questions
* ⏱️ Countdown timer for each question
* 🔀 Randomized questions and answer options
* ✅ Instant feedback (correct/incorrect)
* 📊 Score tracking and percentage calculation
* 🏆 High score saved locally
* 🔄 Restart quiz functionality

---

## 🛠️ Technologies Used

* Flutter (Dart)
* Material UI Components
* SharedPreferences (for local storage)
* Timer (for countdown functionality)

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK installed
* Android Studio / VS Code
* Emulator or physical device

### Installation

1. Clone the repository:

   ```bash
   git clone <your-repo-link>
   ```
2. Navigate to the project folder:

   ```bash
   cd quiz_app
   ```
3. Install dependencies:

   ```bash
   flutter pub get
   ```
4. Run the app:

   ```bash
   flutter run
   ```

---

## 📂 Project Structure

* `main.dart` → Main application logic
* `Question` class → Model for quiz questions
* `QuizHomePage` → Main quiz UI and logic
* `ResultPage` → Displays final score and high score

---

## ⚙️ How It Works

* Questions are initialized and shuffled at the start
* Each question has a 10-second timer
* User selects an answer → instant feedback shown
* Score updates if correct
* At the end, results screen shows:

  * Total score
  * Percentage
  * High score (stored locally)

---

## 🔄 Future Improvements

* Add more questions dynamically (API or database)
* Add categories/difficulty levels
* Improve UI/UX with animations
* Add sound effects

---

## 👨‍💻 Author

Your Name

---

## 📄 License

This project is open-source and free to use.
