# Counter & To‑Do (Flutter + SharedPreferences)

A simple, visually appealing Flutter app demonstrating basic state management with `setState` and persistent local storage using `shared_preferences`.

It includes two tabs:
- Counter: increment/decrement/reset with persisted value
- To‑Do: add, complete, and delete tasks, persisted locally

## Week 2 Objectives Coverage
- Understand basic state management: uses `setState` across the app
- Save and retrieve data locally: `shared_preferences` for counter and to‑do list

## Screenshots
- Counter screen: `screenshots/counter.png`
- To‑Do screen: `screenshots/todo.png`

(Place screenshots under `screenshots/` and update paths as needed.)

## Tech
- Flutter (Material 3, light/dark)
- SharedPreferences for persistence

## Run
```bash
flutter pub get
# Run on Chrome (web)
flutter run -d chrome
# Or Android/iOS
flutter run
```

## Tests
```bash
flutter test
```

## Structure
- `lib/main.dart`: Entire app (bottom nav with Counter and To‑Do)
- Persistence keys:
  - `counter_value`
  - `todo_items`

## Notes
- No external state libraries; only `setState`
- UI kept simple and modern: cards, animations, gradients

---

Made for learning purposes (Week 2: Data Management and Persistent Storage).
