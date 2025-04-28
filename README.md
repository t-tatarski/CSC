🦷 ToothShadeMatcher

ToothShadeMatcher is an open-source project aimed at creating a tool to compare tooth shades across different dental shade guides (Vita Classical A-D, Vita 3D-Master, Ivoclar Chromascop) using CIELAB color space.

The current version is a simple Java console application.
The long-term goal is to build a full mobile app using Flutter for Android and iOS.

🎯 Project Goals
Load tooth shade data from .csv files (shade symbols + CIELAB values),

Allow users to input a shade code (e.g., A3, 2M2, 230),

Calculate color difference (ΔE) between shades,

Find and display the closest matching shades from other shade systems,

Evolve into a full mobile app with Flutter,

Future plans include camera integration and AI-based color detection.

📦 Current Project Structure
bash
Kopiuj
Edytuj
/toothshade-matcher
  |- src/
      |- ColorEntry.java
      |- ColorMatcher.java
  |- sample_data/
      |- vita_classical.csv
      |- chromascop_colors.csv
      |- vita_3d_master_colors.csv
  |- README.md
🚀 How to Run (Java CLI App)
Compile the project:

bash
Kopiuj
Edytuj
javac src/*.java
Run the application:

bash
Kopiuj
Edytuj
java -cp src ColorMatcher
Provide paths to CSV files and enter a shade symbol when prompted.

🔥 Roadmap
 Move shade comparison logic to a RESTful backend (Spring Boot or Dart backend),

 Create a Flutter mobile app:

Input screen for selecting or typing a shade symbol,

Results screen showing closest matches,

Color preview using RGB,

 Future features:

Camera-based color detection,

Advanced color difference calculations (e.g., ΔE 2000),

Full offline mode (no internet required).

🛠️ Tech Stack
Java (backend prototype)

Flutter (planned frontend/mobile)

CSV data handling

CIELAB color space calculations

📜 License
This project is open-sourced under the MIT License.
Contributions, suggestions, and collaborations are highly welcome! 🤝

