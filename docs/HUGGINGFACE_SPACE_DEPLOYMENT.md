# Deploiement Hugging Face Space (Backend API)

Ce guide explique:
- pourquoi tu as deux depots
- comment faire le setup une seule fois
- comment deployer les nouvelles versions ensuite

## 1) Pourquoi deux depots

Tu as deux repositories Git differents, chacun avec un role distinct:

- Depot principal (ton code source): `quran-ai-transcriping`
  - remote `origin`: ton GitHub
  - remote `upstream`: repo source d'origine (optionnel, pour recuperer des updates)
- Depot de deploiement Hugging Face Space: `hf-space-ayat_finder`
  - remote `origin`: `https://huggingface.co/spaces/<user>/<space>`

Un Space Hugging Face est lui-meme un repo Git. Tu pushes du code dans ce repo et HF rebuild automatiquement.
On separe les deux pour eviter de melanger code produit et fichiers specifiques de deploiement.

## 2) Setup initial (une seule fois)

### 2.1 Cloner ton Space localement

```bash
cd /Users/saliouseck/Documents/quran_audio_recognation
git clone https://huggingface.co/spaces/ckroot2009/ayat_finder hf-space-ayat_finder
```

### 2.2 Verifier qu'il contient les fichiers de deploiement

Dans `hf-space-ayat_finder`, il faut au minimum:
- `README.md` avec header YAML (`sdk: docker`, `app_port: 7860`)
- `Dockerfile`
- `.dockerignore`

## 3) Deployer une nouvelle version (recommande)

Depuis le repo principal:

```bash
cd /Users/saliouseck/Documents/quran_audio_recognation/quran-ai-transcriping
scripts/deploy_space.sh
```

Ce script fait automatiquement:
1. sync `app/`, `config/`, `requirements.txt` vers `../hf-space-ayat_finder`
2. `git add` dans le repo Space
3. commit si changements
4. push vers Hugging Face

Ensuite Hugging Face lance le build automatiquement.

## 4) Variantes utiles

### Changer le message de commit

```bash
scripts/deploy_space.sh --message "deploy: fix verse fallback"
```

### Utiliser un autre dossier de clone Space

```bash
scripts/deploy_space.sh --space-dir /chemin/vers/mon/space-clone
```

### Commit local sans push

```bash
scripts/deploy_space.sh --no-push
```

## 5) Verifier le deploiement

1. Ouvrir les logs de build:
   - `https://huggingface.co/spaces/ckroot2009/ayat_finder`
2. Tester la sante de l'API:
   - `https://ckroot2009-ayat-finder.hf.space/health`

## 6) Workflow conseille (simple et propre)

1. Tu codes dans `quran-ai-transcriping`
2. Tu commits et pushes sur ton GitHub (`origin`)
3. Tu lances `scripts/deploy_space.sh`
4. Tu verifies les logs et `/health`

## 7) Notes importantes

- Les Spaces CPU gratuits peuvent se mettre en veille (cold start au prochain appel).
- Le stockage local n'est pas durable pour un usage production.
- Evite d'exposer ton token HF en clair dans des commandes ou des commits.

