# Words of Wonder Adventure — Flutter / Android

A polished, original word-wheel + crossword vocabulary game. It uses its own visual identity and puzzle data rather than proprietary artwork or copied level content from the commercial game.

## Features
- 1,000 numbered levels with progressively larger letter pools and word sets
- Connect letters by tapping them in order, or use the shuffle button
- Crossword-style word slots, automatic placement, and bonus-word discovery
- Hint, reveal-a-letter, and reveal-a-word tools paid for with gems
- Vocabulary cards for a selection of common words
- Progress, gems, discovered bonus words, and settings saved locally
- Offline gameplay; no account or network connection required

## Run in VS Code
1. Install Flutter and Android SDK, then open this folder in VS Code.
2. In the terminal run:
   ```bash
   flutter pub get
   flutter run
   ```
3. If Flutter says the Android device is unsupported because the project metadata is missing, make sure you opened this project root (the folder containing `pubspec.yaml`) and run `flutter create .` once, then `flutter run`.

## Puzzle note
The 1,000 levels are generated deterministically from a curated English word bank. Each level has a primary word and shorter words that can be formed from its letters. The word bank is deliberately local so the game works offline. This is an original fan-made project and is not affiliated with Fugo Games or the commercial Words of Wonders title.
