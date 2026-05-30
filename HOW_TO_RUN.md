# How to Run the Project

This guide explains the minimal steps to run `quran-ai-transcriping` locally.

## 1. Prerequisites

- Python 3.8+
- Node.js + npm
- `ffmpeg` installed and available in `PATH`

## 2. Setup (first time only)

From the project root:

```bash
cd /Users/saliouseck/Documents/quran_audio_recognation/quran-ai-transcriping
make setup
```

This creates `venv/` and installs Python dependencies.

## 3. Build the frontend (first time or after UI changes)

```bash
cd /Users/saliouseck/Documents/quran_audio_recognation/quran-ai-transcriping/frontend
npm install
npm run build
```

This outputs the UI into `../app/static`.

## 4. Start the API + UI

From the project root:

```bash
cd /Users/saliouseck/Documents/quran_audio_recognation/quran-ai-transcriping
source venv/bin/activate
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Open in browser:

- `http://127.0.0.1:8000`

## 5. Quick health check

In another terminal:

```bash
curl http://127.0.0.1:8000/health
```

Expected response example:

```json
{"status":"healthy","worker_running":true,"worker_processing":false,"queue_size":0}
```

## 6. First run note (important)

On first startup, the app downloads the Whisper model from Hugging Face:

- `tarteel-ai/whisper-base-ar-quran`

So the first launch can take longer and requires internet access.

## 7. Optional Make commands

From project root:

```bash
make start         # Build frontend + start backend
make dev-backend   # Start backend only in dev mode
make dev-frontend  # Start frontend dev server (port 5173)
make clean         # Clean temporary files
```

## 8. Troubleshooting

- If UI does not load and `/` shows JSON message:
  - run frontend build again: `cd frontend && npm run build`
- If startup fails on model load:
  - verify internet access and retry
- If audio processing fails:
  - verify `ffmpeg` is installed (`ffmpeg -version`)

## 9. Configure verse tolerance (simple)

You can configure verse matching tolerance without editing Python code.

1. Create a config file from the example:

```bash
cd /Users/saliouseck/Documents/quran_audio_recognation/quran-ai-transcriping
cp config/pipeline_config.example.json config/pipeline_config.json
```

2. Edit `config/pipeline_config.json`:

```json
{
  "verse_min_word_match_ratio": 0.75,
  "verse_similarity_threshold": 0.7,
  "verse_multi_chunk_similarity_floor": 0.6,
  "verse_multi_ayah_similarity_threshold": 0.7,
  "verse_multi_ayah_word_tolerance": 2,
  "verse_allow_low_confidence_fallback": true
}
```

Main setting:
- `verse_min_word_match_ratio`: minimum word-level match ratio per ayah
  - `0.75` means "accept if ~75% of words match"
  - Increase to be stricter (`0.8`, `0.85`)
  - Decrease to be more tolerant (`0.7`)
- `verse_allow_low_confidence_fallback`: if `true`, backend returns best-effort verse mapping when strict mapping fails (instead of failing the job)

3. Restart backend after changes.

## check port usage 
Yes. The error means another process was already listening on `8000` (an old backend instance). I’ve stopped it, and now port `8000` is free.

Use this to run backend again:

```bash
cd /Users/saliouseck/Documents/quran_audio_recognation/quran-ai-transcriping
source venv/bin/activate
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

If it happens again, run this first:

```bash
lsof -nP -iTCP:8000 -sTCP:LISTEN
kill <PID>
```
