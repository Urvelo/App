# Transcript Pro (Flutter Android)

Dark-theme Flutter app (black, gray, white) that can:

- Take a public media URL (for example a YouTube link)
- Pick a local media file
- Transcribe YouTube links with TranscriptAPI (usage-billed API)
- Transcribe long audio/video files with AssemblyAI (optional fallback)
- Improve transcript quality with OpenAI (optional)
- Save transcripts to a local list
- Open a reading mode for completed text
- Export transcript as PDF and share/save it

## 1. Project setup

This repository contains app code in `lib/` and `pubspec.yaml`.
If your project does not yet have platform folders, generate Android files:

```bash
flutter create --platforms=android .
flutter pub get
```

## 2. API keys

Recommended API key for your current setup:

- `TRANSCRIPT_API_KEY` (for YouTube transcript extraction)

Optional keys:

- `ASSEMBLYAI_API_KEY` (for file and non-YouTube URL transcription)
- `OPENAI_API_KEY` (for AI text improvement)

Run example:

```bash
flutter run \
	--dart-define=TRANSCRIPT_API_KEY=YOUR_TRANSCRIPT_API_KEY \
	--dart-define=OPENAI_API_KEY=YOUR_OPENAI_KEY
```

## 3. Build APK

```bash
flutter build apk --release \
	--dart-define=TRANSCRIPT_API_KEY=YOUR_TRANSCRIPT_API_KEY \
	--dart-define=OPENAI_API_KEY=YOUR_OPENAI_KEY
```

APK output:

`build/app/outputs/flutter-apk/app-release.apk`

## 4. Build APK without local Flutter (GitHub Actions)

Workflow file: `.github/workflows/android-apk.yml`

1. Add repository secrets:
	 - `TRANSCRIPT_API_KEY`
	 - `OPENAI_API_KEY` (optional)
	 - `ASSEMBLYAI_API_KEY` (optional)
2. Open Actions tab
3. Run workflow: `Build Android APK`
4. Download artifact: `app-release-apk`
5. Install APK on your phone

## 5. Notes

- YouTube transcripts are fetched from TranscriptAPI (`/api/v2/youtube/transcript`).
- File transcription and non-YouTube URL transcription use AssemblyAI when key is provided.
- Local transcript list is stored in app documents as JSON.