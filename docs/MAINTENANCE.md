# Plan de maintenance — Mobile Ressources Relationnelles

## Outillage de gestion des évolutions

Le suivi opérationnel s'appuie sur **deux outils complémentaires** :

- **GitHub Issues + Projects** — catalogue technique des fonctionnalités, anomalies et tâches techniques. Chaque issue est liée nativement aux commits, branches et pull requests (closing keywords, mentions, références croisées) : la traçabilité code ↔ ticket est automatique. Les templates structurés (`.github/ISSUE_TEMPLATE/bug_report.md`, `feature_request.md`) garantissent que chaque demande contient les informations nécessaires.

- **Trello** — pilotage opérationnel quotidien : visualisation kanban, priorisation visuelle, planification de sprint, répartition des assignations dans l'équipe. Les cartes Trello en cours référencent les issues GitHub correspondantes.

Cette articulation découpe les responsabilités : **GitHub Issues = source de vérité technique** (lié au code), **Trello = vue de pilotage** (lié à l'équipe).

---

## Gestion des tickets

### Labels GitHub recommandés

| Label | Couleur | Usage |
|---|---|---|
| `bug` | Rouge (`#d73a4a`) | Anomalie, régression, comportement inattendu |
| `feature` | Bleu (`#0075ca`) | Nouvelle fonctionnalité demandée |
| `security` | Orange (`#e4a42b`) | Vulnérabilité, faille de sécurité, confidentialité |
| `dependencies` | Vert (`#0e8a16`) | Mise à jour dépendance (Dependabot) |
| `a11y` | Violet (`#6f42c1`) | Non-conformité accessibilité WCAG |
| `priority:critical` | Rouge foncé (`#b60205`) | Bloquant critique — traitement immédiat |
| `priority:high` | Orange (`#d93f0b`) | Majeur — traitement prioritaire |
| `priority:medium` | Jaune (`#fbca04`) | Mineur — planifié en sprint |
| `priority:low` | Gris (`#cfd3d7`) | Cosmétique, futur |
| `platform:android` | Bleu ciel (`#0099cc`) | Concerne Android seulement |
| `platform:ios` | Gris (`#cccccc`) | Concerne iOS seulement |
| `screen:login` | — | Concerne écran login |
| `screen:ressources` | — | Concerne écran ressources |
| `screen:messagerie` | — | Concerne écran messagerie |
| `screen:account` | — | Concerne profil/compte |

### Templates d'issues

Fichiers disponibles dans `.github/ISSUE_TEMPLATE/` :

**Bug report** (`.github/ISSUE_TEMPLATE/bug_report.md`) :
- Étapes de reproduction (numérotées)
- Comportement attendu vs observé
- Logs d'erreur (masquer tokens, mots de passe, données perso)
- Environnement : version Flutter, OS, device, rôle utilisateur
- Lien vers commit/branch si connu

**Feature request** (`.github/ISSUE_TEMPLATE/feature_request.md`) :
- Contexte utilisateur / besoin métier
- Description de la fonctionnalité souhaitée
- Critères d'acceptation (liste vérifiable)
- Maquettes ou exemples si disponibles
- Écrans impactés

**Security report** — **pas d'issue publique**. Contacter DPO via email privé au lieu de GitHub.

### GitHub Project board (Kanban)

Structure recommandée :

```
┌──────────┬──────────────┬───────────┬──────┐
│ Backlog  │ In Progress  │ In Review │ Done │
├──────────┼──────────────┼───────────┼──────┤
│ Issues   │ Branches     │ PRs       │ PRs  │
│ triées   │ en cours     │ ouvertes  │ mergées
└──────────┴──────────────┴───────────┴──────┘
```

- Chaque issue associée à une **Milestone** (ex. `v1.0.0`, `v1.1.0`, `v2.0.0`)
- Labels `priority:*` et `platform:*` / `screen:*` pour tri et assignation
- Issues fermées automatiquement via closing keywords dans PRs (`Fixes #123`)

---

## Niveaux de priorité et SLA

| Priorité | Définition | Prise en charge | Résolution |
|----------|-----------|:-----:|:-----:|
| **Bloquant critique** | App crash global, perte de données, faille sécurité active, inaccessibilité totale | 1 h | 4 h (code) + 24-72 h (store) |
| **Majeur** | Fonctionnalité clé dégradée (login, ressources, messagerie) | 4 h | 1 jour ouvré (code) + délai store |
| **Mineur** | Anomalie cosmétique, texte erroné, lien cassé, perf dégradée | 1 jour ouvré | 1 semaine |
| **Amélioration** | Feature request, UX non-bloquant | Best effort | Planification sprint suivant |

**Importante** : délai store (24–72 h Google Play, 1–3 j App Store) s'ajoute au délai code. Un correctif critique mobile peut prendre jusqu'à **72h–3j** pour atteindre tous les utilisateurs.

**Mitigation** : kill switch côté backend pour désactiver fonctionnalité critique le temps que l'app se diffuse.

---

## Procédure de gestion d'incident

### Étape 1 — Détection

Les incidents sont détectés par :
- **Utilisateur** : signalement via GitHub Issues ou `/contact` frontend
- **Monitoring externe** (roadmap V1.1) : Firebase Crashlytics, UptimeRobot
- **Audit manuel** : revue code, tests E2E

### Étape 2 — Diagnostic

```bash
# 1. Reproduire localement
flutter clean
flutter pub get
flutter run

# 2. Consulter les logs Flutter
flutter logs

# 3. Vérifier que le backend est accessible
curl http://localhost:3001/health

# 4. Si crash crash : vérifier Firebase Crashlytics (roadmap V1.1)
# → https://console.firebase.google.com

# 5. Analyser l'issue GitHub : reproduction steps, environnement
```

### Étape 3 — Correction

```bash
# 1. Créer branche depuis main
git checkout main
git pull origin main
git checkout -b hotfix/description-courte

# 2. Appliquer le correctif dans lib/
# ... modifications ...

# 3. Tester localement
flutter test
flutter run

# 4. Mettre à jour pubspec.yaml (version bump)
# version: x.y.z+n → version: x.y.(z+1)+(n+1)

# 5. Commit
git add .
git commit -m "hotfix(screen): <description>"

# 6. Push et PR vers main
git push origin hotfix/description-courte
```

La PR doit :
- Passer tous les checks CI (analyze, test, build APK)
- Être approuvée par au moins un autre développeur
- Être mergée en **squash merge** pour historique lisible

### Étape 4 — Post-mortem

Ajouter un commentaire dans l'issue GitHub fermée :

```
## Post-mortem — Incident X

**Cause racine** : [qu'est-ce qui a provoqué l'incident ?]

**Impact** : [durée, fonctionnalités affectées, utilisateurs estimés]

**Chronologie** :
- 14:30 — Détection utilisateur
- 14:45 — Diagnostic confirme bug
- 15:30 — Correctif code prêt
- 15:45 — PR mergée sur main
- 15:50 — APK debug en artifact CI
- [Si store] 24-72h — utilisateurs reçoivent update

**Mesures préventives** : [test ajouté ? refactor ? alerte ?]
```

---

## Calendrier de maintenance préventive

### Hebdomadaire

- [ ] Exécuter `flutter pub outdated` et vérifier vulnérabilités hautes :
  ```bash
  flutter pub outdated --mode=null-safety
  flutter pub upgrade
  ```
- [ ] Vérifier alertes **Dependabot** ouvertes sur GitHub
- [ ] Exécuter `flutter analyze` sur le code :
  ```bash
  flutter analyze --no-fatal-infos --no-fatal-warnings
  ```
- [ ] Vérifier que les jobs CI passent sur `main`

### Mensuel

- [ ] Tester le build complet (debug + release) :
  ```bash
  flutter clean
  flutter pub get
  flutter build apk --release
  ```
- [ ] Exécuter la suite de tests :
  ```bash
  flutter test
  ```
- [ ] Vérifier l'accès API backend en développement (`curl http://localhost:3001/health`)
- [ ] Revoir les issues ouvertes sur GitHub et ajuster priorités
- [ ] Vérifier l'état des comptes de démonstration (tous les rôles)

### Trimestriel

- [ ] Mettre à jour **Flutter SDK** vers latest stable :
  ```bash
  flutter upgrade
  flutter channel stable
  flutter upgrade
  ```
- [ ] Mettre à jour dépendances majeures (après lecture release notes) :
  ```bash
  flutter pub upgrade --major-versions
  # Tester build + tests après
  ```
- [ ] Vérifier obsolescence de `flutter_dsfr` (équipe SIG)
- [ ] Audit complet permissions Android/iOS
- [ ] Revoir liste des tests (couverture)

### Annuel

- [ ] **Revue de sécurité complète** (voir `SECURITY.md`) :
  ```bash
  flutter pub audit
  # Audit manuel : vérifier RGPD, permissions, stockage données
  ```
- [ ] Rotation secrets (`AUTH_TOKEN_SECRET` backend, keystore Android)
- [ ] Renouvellement certificat Apple Developer (si V1.1)
- [ ] Audit RGPD complet (conservation données, droits utilisateurs)
- [ ] Revoir conformité app stores (Google Play, App Store guidelines)

---

## Versioning et numbering

Format `pubspec.yaml` :

```yaml
version: <MAJOR>.<MINOR>.<PATCH>+<BUILD_NUMBER>
# Exemple : 1.0.0+1
```

**Règles** :

- `<MAJOR>` : changement incompatible (redesign, changement API majeur)
- `<MINOR>` : nouvelle fonctionnalité rétrocompatible
- `<PATCH>` : correctif
- `+<BUILD_NUMBER>` : numéro monotone (requis Google Play à chaque release)

**Progression exemple** :

```
v1.0.0+1    → v1.0.1+2 (hotfix)
v1.0.1+2    → v1.1.0+3 (feature iOS)
v1.1.0+3    → v1.1.1+4 (bug fix)
v1.1.1+4    → v2.0.0+5 (redesign majeur)
```

À chaque release, créer un tag git :

```bash
git tag v1.0.1
git push origin v1.0.1
```

---

## Procédure de release

### Checklist avant release

- [ ] Tous tests passent : `flutter test`
- [ ] Lint OK : `flutter analyze`
- [ ] Code review approuvée
- [ ] Changelog mis à jour (`CHANGELOG.md`)
- [ ] Version `pubspec.yaml` bumped
- [ ] Build local valide : `flutter build apk --release`
- [ ] Équipe notifiée (heure, durée, rollback plan)

### Build + publication

```bash
# 1. S'assurer sur main + synchronized
git checkout main
git pull origin main

# 2. Incrémenter version pubspec.yaml
nano pubspec.yaml
# version: 1.0.0+1 → version: 1.0.1+2

# 3. Build APK signé (V1.1, keystore confié)
flutter build apk --release --...

# 4. Mettre à jour CHANGELOG.md
nano CHANGELOG.md
# Ajouter section : ## [1.0.1] - 2026-06-06

# 5. Commit de version
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): v1.0.1"
git push origin main

# 6. Tag
git tag v1.0.1
git push origin v1.0.1

# 7. Publier sur stores (via browser ou CLI)
# Google Play Console : upload APK / App Bundle
# App Store Connect (V1.1) : upload IPA via Transporter
```

### Après publication

- [ ] Surveiller retours utilisateurs (GitHub Issues)
- [ ] Vérifier que la version est bien disponible sur store (2–4 h délai caching)
- [ ] Tester l'app depuis le store (pas juste en dev local)

---

## Dépendances critiques

| Package | Rôle | Fréquence vérification |
|---------|------|---|
| `flutter` | Framework principal | Mensuel |
| `dart` | Runtime | Mensuel (via `flutter upgrade`) |
| `http` | Client HTTP | Mensuel |
| `image_picker` | Upload photos | Trimestriel |
| `flutter_dsfr` | Composants UI | Trimestriel |
| `intl` | Formatage dates | Mensuel |

**Procédure mise à jour dépendance** :

```bash
# Vérifier versions disponibles
flutter pub outdated

# Mettre à jour spécifique
flutter pub add http:^1.7.0

# Ou upgrade tous
flutter pub upgrade

# Tester
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

---

## Monitoring et observabilité

### Firebase Crashlytics — Roadmap V1.1

Capturer les crashes runtime côté mobile.

**Configuration** :

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^latest
  firebase_crashlytics: ^latest
```

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(const App());
}
```

**Consultation** : [console.firebase.google.com](https://console.firebase.google.com) → Crashlytics.

### Monitoring externe (recommandé)

| Outil | Type | Coût | Usage |
|---|---|---|---|
| **UptimeRobot** | SaaS, sonde HTTP | Gratuit | Vérifier que backend répond |
| **Uptime Kuma** | Self-hosted Docker | Gratuit | Alternative self-hosted |

Configurer sonde sur `http://localhost:3001/health` (ou URL prod).

### Logs application

En mode debug :

```bash
flutter logs       # Affiche logs temps réel
flutter logs -c    # Logs avec couleurs
```

Pas de logs verbose en release (données sensibles). Aucune exposition de token ou email dans `print()`.

---

## Checklist SLA par incident

| Priorité | Prise en charge | Code fixé | Utilisateurs reçoivent | Total |
|----------|:---:|:---:|:---:|:---:|
| Critique | 1 h | 4 h | +72 h (store) | **~75 h max** |
| Majeur | 4 h | 24 h | +24-72 h | **~96 h max** |
| Mineur | 1 jour | 1 semaine | +24-72 h | **~10 jours** |

**Stratégie de mitigation critique** : désactiver côté backend (kill switch) le temps que l'app se diffuse.

---

## Incidents connus et contournements

### Android — backend ne rejoint pas localhost

**Symptôme** : erreur `SocketException` lors de l'appel API depuis l'émulateur.

**Diagnostic** :
1. Backend tourne ? `curl http://localhost:3001/health`
2. Émulateur connecté ? `flutter devices`
3. Firewall local bloque 3001 ? Vérifier pare-feu Windows

**Contournement** :
```dart
// lib/shared/api_service.dart
// Remplacer 10.0.2.2 par 192.168.x.x (IP locale) si sur LAN
const String _base = 'http://192.168.1.50:3001';
```

### iOS — HTTP non chiffré bloqué

**Symptôme** : `NSURLErrorDomain -1200` sur simulateur iOS.

**Solution** : ajouter dans `ios/Runner/Info.plist` (dev uniquement) :

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

Supprimer cette clé en production (HTTPS obligatoire).

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
# Génère apk par architecture (arm64-v8a, armeabi-v7a)
# Taille réduite à ~30-50 MB chaque
```

---

## Ressources externes

- [Flutter docs](https://docs.flutter.dev)
- [Dart documentation](https://dart.dev/guides)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Flutter DSFR](https://github.com/betagouv/flutter_dsfr)
- Repo GitHub : [ressources-relationnelles-CESI-EFTEG/mobile](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile)
- Backend docs : `../backend/docs/MAINTENANCE.md`
