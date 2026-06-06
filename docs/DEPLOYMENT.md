# Plan de déploiement — Mobile Ressources Relationnelles

## Architecture générale

```
                    Développement local / Test / Production
                              │
        ┌─────────────────────┴─────────────────────┐
        │                                           │
    [Mobile Flutter — Android/iOS]             [Backend NestJS :3001]
        │                                           │
        └──────────── API REST (HTTP/HTTPS) ───────┘
                                   │
                          [PostgreSQL :5432]
```

Le client mobile Flutter communique exclusivement avec l'API backend. Aucune logique métier n'est traitée côté mobile — il s'agit d'une interface utilisateur stateless qui transmet les requêtes au backend et affiche les réponses.

---

## Environnements

| Environnement | Target | URL backend | Mode build | Plateforme |
|---|---|---|---|---|
| **Développement** | Émulateur Android / Simulateur iOS | `http://10.0.2.2:3001` (Android) `http://127.0.0.1:3001` (iOS) | Debug | Android + iOS |
| **Test** | Appareil physique (LAN) | `http://<IP-hôte>:3001` | Debug | Android + iOS |
| **Pré-production** | Appareil physique / Firebase | HTTPS `https://api.test.rr.gouv.fr` | Release | Android + iOS (roadmap) |
| **Production** | Google Play / App Store | HTTPS `https://api.rr.gouv.fr` | Release | Android (v1.0) + iOS (v1.1) |

---

## Prérequis

### Locaux

- **Flutter SDK** version `^3.11.0` (avec Dart intégré)
  - Vérifier : `flutter --version`
- **Android Studio** ou **Xcode** pour l'émulation
- **Backend Ressources Relationnelles** en exécution locale ou accessible réseau
- **Git** pour le contrôle de version
- **npm** (pour le backend, si lancé localement)

### Installation Flutter SDK

1. Télécharger depuis [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Ajouter le répertoire `flutter/bin` au `PATH`
3. Exécuter `flutter doctor` pour vérifier toutes les dépendances

```bash
flutter doctor
# Vérifie :
# - Flutter SDK
# - Android SDK / Xcode
# - Connexion à Internet
# - Émulateur/simulateur disponible
```

### Émulateur Android

```bash
# Lancer l'émulateur (défaut Pixel 4 API 34)
emulator -avd Pixel_4_API_34

# Ou via Flutter
flutter emulators
flutter emulators launch Pixel_4_API_34
```

### Simulateur iOS

```bash
# Lancer le simulateur (défaut : dernière version iOS disponible)
open -a Simulator

# Ou via Xcode
xcrun simctl list
xcrun simctl boot <device-id>
```

---

## Configuration URL backend

### État actuel (V1.0)

L'URL de base est codée en dur dans `lib/shared/api_service.dart` (ligne 5) :

```dart
const String _base = 'http://10.0.2.2:3001';
```

**Cible actuelle** : émulateur Android uniquement.

### Adaptation selon la cible

| Cible | `_base` | Raison |
|---|---|---|
| Émulateur Android | `http://10.0.2.2:3001` | Alias système vers localhost de l'hôte |
| Simulateur iOS | `http://127.0.0.1:3001` | Simulateur partage l'IP de la machine hôte |
| Appareil physique (même LAN) | `http://<IP-hôte>:3001` | Remplacer par l'IP de la machine exécutant le backend |
| Production (HTTPS) | `https://api.rr.gouv.fr` | Certificat TLS déployé côté backend |

**Procédure changement :**

```bash
# 1. Éditer api_service.dart
nano lib/shared/api_service.dart

# 2. Remplacer la valeur de _base (ligne 5)
const String _base = 'http://127.0.0.1:3001';  # par exemple pour iOS

# 3. Recompiler
flutter clean
flutter pub get
flutter run
```

### Roadmap V1.1 : environnement via `--dart-define`

Passer l'URL en variable de compilation au lieu de la coder en dur :

```bash
flutter run --dart-define=API_BASE=http://192.168.1.50:3001

# Ou en build release
flutter build apk --release --dart-define=API_BASE=https://api.rr.gouv.fr
```

Accès dans le code :

```dart
const String apiBase = String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:3001');
const String _base = apiBase;
```

**Avantage** : éviter les recompilations pour changer d'URL, activer les fichiers `.env` via `flutter_dotenv` ultérieurement.

---

## Build Android

### Prérequis

- Android SDK (installé via Android Studio, API 24 minimum, cible API 34+ recommandée)
- `ANDROID_SDK_ROOT` ou `ANDROID_HOME` pointant vers le SDK
- Clé privée de signature (keystore) pour les builds release

### Build APK Debug

```bash
cd <chemin/vers/mobile>
flutter clean
flutter pub get
flutter build apk --debug
```

Sortie : `build/app/outputs/apk/debug/app-debug.apk`

**Taille** : ~80–120 MB (non optimisé, symboles de debug inclus).

Installez l'APK sur un appareil/émulateur :

```bash
adb install build/app/outputs/apk/debug/app-debug.apk
```

### Build APK Release (non signé)

```bash
flutter build apk --release
```

Sortie : `build/app/outputs/apk/release/app-release.apk`

**Taille** : ~30–50 MB (optimisé, symboles supprimés).

### Build APK Release (signé) — Roadmap V1.1

**Créer une clé de signature** (une seule fois) :

```bash
keytool -genkey -v -keystore ~/ressources-relationnelles.jks \
  -keyalg RSA -keysize 2048 -validity 36500 \
  -alias ressources-relationnelles-key
```

Arguments interactifs :
- Mot de passe keystore : `<motdepassefort>`
- Prénom/nom : Ressources Relationnelles
- Organisation : CESI EFTEG
- Ville : Paris
- État : Île-de-France
- Code pays : FR

**Build signé** :

```bash
flutter build apk --release \
  --keystore ~/ressources-relationnelles.jks \
  --keystore-password <motdepassefort> \
  --key-alias ressources-relationnelles-key \
  --key-password <motdepassefort>
```

Alternativement, créer `android/key.properties` (à ajouter au `.gitignore`) :

```properties
storeFile=/chemin/vers/ressources-relationnelles.jks
storePassword=<motdepassefort>
keyAlias=ressources-relationnelles-key
keyPassword=<motdepassefort>
```

Puis :

```bash
flutter build apk --release
```

### App Bundle (Google Play)

Format requis par Google Play Store (contient plusieurs APK optimisés par appareil).

```bash
flutter build appbundle --release
```

Sortie : `build/app/outputs/bundle/release/app-release.aab`

---

## Build iOS — Roadmap V1.1

**Prérequis** :
- macOS (obligatoire)
- Xcode `^15.0`
- Certificats de développement Apple (téléchargés dans Xcode)
- Identifiants d'application (App ID) enregistrés auprès d'Apple

**Compilation** :

```bash
flutter build ios --release
# Sortie : build/ios/iphoneos/Runner.app

# Ou, pour générer un fichier .ipa (archive) :
flutter build ios --release --build-number=<buildNumber>
# Puis compresser avec Xcode
```

**Note** : les builds iOS dépendent d'un runner macOS. Les GitHub Actions gratuites ne supportent pas macOS — les builds iOS devront être effectués localement ou via des runners GitHub payants (~30 €/mois).

---

## Distribution

### V1.0 — Artefact GitHub Actions (Debug)

La CI GitHub Actions (`.github/workflows/ci.yml`) construit un APK debug à chaque push sur `main`, `preprod` et `develop` :

```yaml
- name: Build Android APK (debug)
  run: flutter build apk --debug
- name: Upload artifact
  uses: actions/upload-artifact@v3
  with:
    name: android-debug-apk
    path: build/app/outputs/apk/debug/app-debug.apk
```

**Utilisation** :
1. Après un push sur `main`, `preprod` ou `develop`, attendre la fin du workflow CI.
2. Télécharger l'APK depuis l'onglet "Actions" de GitHub.
3. Installer manuellement sur un appareil/émulateur.

### V1.1 — Firebase App Distribution

**Prérequis** :
- Compte Firebase (console.firebase.google.com)
- Projet Firebase créé pour Ressources Relationnelles
- Groupe de testeurs internes créé dans Firebase Console

**Configuration GitHub Secrets** :

```bash
# Générer un token de service Firebase
firebase login:ci  # crée un token stocké localement

# Dans GitHub : Settings → Secrets → FIREBASE_TOKEN = <token>
```

**Workflow** :

```yaml
- name: Build APK signed
  run: flutter build apk --release --...

- name: Upload to Firebase App Distribution
  run: |
    firebase appdistribution:distribute \
      build/app/outputs/apk/release/app-release.apk \
      --app=<APP_ID> \
      --release-notes="Release from ${{ github.sha }}" \
      --testers-file=testers.txt
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

### Production — Google Play Store / App Store

**Google Play Store** (Android) :

1. Créer un compte développeur Google Play (~25 $ une seule fois).
2. Créer l'application dans la Console Play.
3. Uploader l'App Bundle signé (`.aab`).
4. Définir le store listing (titre, description, images, catégorie, contenu).
5. Soumettre à révision (~24–72 h).

**Apple App Store** (iOS, V1.1) :

1. Créer un compte développeur Apple (~100 $ par an).
2. Enregistrer l'App ID et les certificats dans Apple Developer Program.
3. Générer un build signé (`.ipa`).
4. Uploader via Transporter (outil Apple) ou TestFlight pour test bêta.
5. Soumettre à révision (~1–3 jours).

---

## Délais de publication

| Store | Délai | Remarque |
|---|---|---|
| Google Play | 24–72 h | Révision automatisée, feedback immédiat |
| App Store | 1–3 jours | Révision manuelle, critères strictes (data privacy, usage permissions) |

**Implication** : une correction de sécurité critique peut prendre jusqu'à 72h pour atteindre tous les utilisateurs après merging et publication. Stratégie de mitigation : kill switch côté backend.

---

## Rollback

### Stratégie de rollback mobile

**Le rollback en tant que tel ne s'applique pas** aux stores publiques : Google Play et App Store ne permettent pas de "retirer" une version déjà téléchargée. Les utilisateurs gardent l'APK/IPA installée.

**Stratégie alternative** :

1. **Version précédente publiée** : si une nouvelle version cause une régression critique, publier immédiatement une version hotfix (ex. v1.0.1 → v1.0.2).
2. **Git tag** : conserver accès au code source de chaque version via tags sémantiques :
   ```bash
   git tag v1.0.0
   git checkout v1.0.0
   flutter build apk --release
   ```
3. **Kill switch côté backend** : si la faille est bloquante et impacte tous les utilisateurs, désactiver la fonctionnalité côté API (feature flag, état endpoint) le temps que la mise à jour se diffuse.

### Procédure en cas de bug critique

```bash
# 1. Branche hotfix depuis main
git checkout main
git pull origin main
git checkout -b hotfix/description-courte

# 2. Appliquer la correction dans lib/ et pubspec.yaml (version bump)
# Exemple : version: 1.0.0+1 → version: 1.0.1+2
nano pubspec.yaml

# 3. Commit
git add .
git commit -m "hotfix(mobile): <description>"

# 4. Push et PR vers main
git push origin hotfix/description-courte

# 5. Une fois mergée sur main :
# - Attendre CI = apk debug en artifact
# - Ou builder localement en release
flutter build apk --release

# 6. Publier sur Google Play (V1.0) / Firebase (V1.1)
# 7. Tag
git tag v1.0.1
git push origin v1.0.1

# 8. Propager le hotfix en aval (preprod et develop)
#    pour éviter qu'il ne soit écrasé au prochain merge normal
git checkout preprod && git pull && git merge --no-ff origin/main && git push
git checkout develop && git pull && git merge --no-ff origin/preprod && git push
```

---

## Versioning

Ressources Relationnelles mobile suit **Semantic Versioning** :

**Format pubspec.yaml** :

```yaml
version: <MAJOR>.<MINOR>.<PATCH>+<BUILD_NUMBER>
# Exemple : 1.0.0+1
```

- `<MAJOR>` : changement incompatible (ex. redesign UI, changement API)
- `<MINOR>` : nouvelle fonctionnalité rétrocompatible (ex. ajout feature)
- `<PATCH>` : correctif (ex. bug fix)
- `+<BUILD_NUMBER>` : numéro de build pour les stores (monotone, requis par Google Play)

**Exemple de progression** :

```
v1.0.0+1 (release Google Play)
v1.0.1+2 (hotfix)
v1.1.0+3 (nouvelle feature, iOS support)
v2.0.0+4 (redesign majeur)
```

À chaque modification de version pour une release, créer un tag git :

```bash
git tag v1.0.1
git push origin v1.0.1
```

---

## CI/CD

### Stratégie GitFlow

Le projet suit un GitFlow à **quatre branches d'intégration** :

```
feat/* | fix/* | chore/* | docs/*
        │
        ▼
     develop ──► preprod ──► main
```

| Branche | Rôle | Cible de déploiement |
|---|---|---|
| `develop` | Intégration des fonctionnalités terminées | Build APK debug — testeurs internes |
| `preprod` | Stabilisation et validation finale avant publication store | Distribution Firebase App Distribution (**roadmap V1.1**) — testeurs élargis |
| `main` | Version stable de production, taguée par release | Publication Google Play / App Store |

Chaque fusion `develop → preprod` puis `preprod → main` passe par une pull request avec revue de code et validation des status checks.

### Workflow GitHub Actions (`.github/workflows/ci.yml`)

Déclenché à chaque push et pull request sur `main`, `preprod` et `develop` :

| Étape | Commande | Artefact |
|---|---|---|
| **Analyze** | `flutter analyze --no-fatal-infos --no-fatal-warnings` | — |
| **Test** | `flutter test` (si tests présents) | Coverage report |
| **Build Android APK** | `flutter build apk --debug` | `app-debug.apk` |
| **Artifact upload** | `actions/upload-artifact@v3` | APK en téléchargement |

### Protection des branches `main` et `preprod`

- [ ] Exiger que les PRs passent tous les checks CI avant merge
- [ ] Exiger au moins une approbation avant merge
- [ ] Interdire les push directs sur `main` et `preprod` (passer par PR)

Configurer via **GitHub Settings → Branches → Branch protection rules** pour `main` et `preprod`.

---

## Démarrage local — développement

```bash
# 1. Cloner le repo
git clone https://github.com/ressources-relationnelles-CESI-EFTEG/mobile.git
cd mobile

# 2. Installer les dépendances
flutter pub get

# 3. Démarrer le backend (autre terminal)
cd ../backend
npm run start:dev
# Vérifie : curl http://localhost:3001/health

# 4. Lancer l'application (émulateur doit être en cours)
flutter run

# 5. Ou spécifier un device
flutter devices        # lister les appareils
flutter run -d <device-id>
```

Accès app : simulateur/émulateur affiche l'écran de connexion.

---

## Sécurité des secrets

### V1.0 — Pas de secrets mobile

L'application n'embarque aucun secret (clé API, token). Tous les secrets sont gérés côté backend (auth token, credentials BDD).

### V1.1 Roadmap — Keystore signatures

**Sécuriser la clé privée** (`ressources-relationnelles.jks`) :

- [ ] Ne pas committer le fichier `.jks` dans Git (ajouter à `.gitignore`)
- [ ] Stocker sur une machine de confiance, sauvegardé en lieu sûr
- [ ] Utiliser GitHub Secrets pour les mots de passe (voir section Secrets CI/CD)

**GitHub Secrets pour CI/CD** :

```bash
# Dans Settings → Secrets and variables → Actions :
ANDROID_KEYSTORE_BASE64=<base64_du_fichier_jks>
KEY_ALIAS=ressources-relationnelles-key
KEY_PASSWORD=<motdepasse>
STORE_PASSWORD=<motdepasse>
```

**Workflow CI** (décodage) :

```yaml
- name: Decode Keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > keystore.jks
    
- name: Build APK signed
  run: flutter build apk --release \
    --keystore=keystore.jks \
    --keystore-password=${{ secrets.STORE_PASSWORD }} \
    --key-alias=${{ secrets.KEY_ALIAS }} \
    --key-password=${{ secrets.KEY_PASSWORD }}
```

---

## FAQ / Pièges connus

### iOS bloque HTTP
**Symptôme** : sur simulateur iOS, les requêtes échouent avec `NSURLErrorDomain -1200`.

**Solution** : ajouter dans `ios/Runner/Info.plist` pour développement :

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

En production, passer en HTTPS et supprimer cette clé.

### Émulateur Android ne rejoint pas localhost
**Symptôme** : `flutter run` échoue, ne peut pas joindre `10.0.2.2:3001`.

**Vérification** :
1. Backend tourne-t-il sur :3001 ? `curl http://localhost:3001/health`
2. Appareil est-il connecté ? `flutter devices`
3. Firewall bloque-t-il le port 3001 ? Vérifier pare-feu local

**Contournement** : utiliser l'adresse IP réelle si sur le même LAN (ex. `192.168.1.50`).

### `flutter pub get` échoue
**Solution** :
```bash
flutter clean
rm pubspec.lock
flutter pub get
```

### APK trop volumineux (> 150 MB)
**Optimisation** :
```bash
flutter build apk --release --split-per-abi
# Génère app-arm64-v8a-release.apk (~30-50 MB) + variantes
```

---

## Ressources externes

- [Flutter docs — deployment](https://docs.flutter.dev/deployment)
- [Google Play — publish guidelines](https://support.google.com/googleplay/android-developer)
- [App Store — app review guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Flutter DSFR (`flutter_dsfr`)](https://github.com/betagouv/flutter_dsfr)
- Repo GitHub : [ressources-relationnelles-CESI-EFTEG/mobile](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile)
