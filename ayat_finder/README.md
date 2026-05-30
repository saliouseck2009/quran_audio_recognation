# Ayat Finder (Flutter)

Application mobile d’identification de récitations coraniques.

## Fonctionnalités implémentées

- Onboarding + permission microphone
- État idle (prêt à écouter)
- Enregistrement (start, pause/reprise, stop, annuler)
- Envoi audio vers l’API async (`/transcribe/async`)
- Analyse avec suivi d’étapes (audio reçu, transcription, correspondance)
- Résultat mono-verset et séquence de versets
- Écran d’erreur (aucun verset reconnu / erreur réseau)
- Historique local des reconnaissances

## Lancer l’app

```bash
cd quran-ai-transcriping/ayat_finder
flutter pub get
flutter run
```

## Backend attendu

L’app appelle le backend FastAPI sur:

`http://127.0.0.1:8000`

La base URL est définie dans:

- `lib/src/app.dart`

Si tu testes sur un émulateur Android, remplace `127.0.0.1` par `10.0.2.2`.

Sur appareil réel, lance avec `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.107:8000
```

## Endpoints utilisés

- `POST /transcribe/async`
- `GET /jobs/{job_id}/status`
- `GET /jobs/{job_id}/metadata`
