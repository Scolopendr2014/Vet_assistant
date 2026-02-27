# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

Flutter desktop/mobile app «Ассистент ветеринара» (Veterinary Assistant) — self-contained app with embedded SQLite (Drift ORM), no backend services required. See `README.md` for feature details.

### Flutter SDK version

The codebase requires **Flutter ≥ 3.35** (stable channel). Earlier versions will fail `flutter analyze` because the code uses `DropdownButtonFormField(initialValue:)` (added in 3.35) and `Color.withValues()` (added in 3.27). The SDK is installed at `/opt/flutter` and is on `PATH` via `~/.bashrc`.

### Key commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Code generation | `dart run build_runner build --delete-conflicting-outputs` |
| Lint | `flutter analyze` |
| Tests | `flutter test` |
| Build Linux | `flutter build linux` |
| Run Linux | `build/linux/x64/release/bundle/vet_assistant` |

### Gotchas

- **Linux desktop must be enabled**: run `flutter config --enable-linux-desktop` once per environment.
- **`xdg-user-dirs` required at runtime**: the `path_provider` plugin needs `xdg-user-dir` to locate the documents directory on Linux. Install it with `sudo apt-get install -y xdg-user-dirs` and run `xdg-user-dirs-update` before launching the app.
- **`libstdc++-14-dev` for clang builds**: on Ubuntu 24.04 with clang-18, `flutter build linux` fails with `'type_traits' file not found` unless GCC 14 C++ standard library headers are installed (`sudo apt-get install -y libstdc++-14-dev`). A `libstdc++.so` symlink may also be needed: `sudo ln -sf /usr/lib/gcc/x86_64-linux-gnu/14/libstdc++.so /usr/lib/x86_64-linux-gnu/libstdc++.so`.
- **`flutter analyze` shows 2 warnings** in auto-generated `app_database.g.dart` — these are harmless and come from Drift code generation.
- **All 55 tests pass** via `flutter test` using in-memory SQLite (`AppDatabase.forTest()`).
- Commit messages should follow the format in `CONTRIBUTING.md` with artifact IDs from `docs/ARTIFACTS.md`.
