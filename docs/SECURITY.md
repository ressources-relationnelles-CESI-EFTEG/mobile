# Plan de sécurisation — Mobile Ressources Relationnelles

## Matrice OWASP Mobile Top 10 (2024)

L'OWASP Mobile Top 10 est distinct de l'OWASP Web Top 10. Il cible les vulnérabilités spécifiques aux applications mobiles.

| # | Risque OWASP Mobile | Statut | Mesures appliquées dans RR Mobile |
|---|---|---|---|
| **M1** | Improper Credential Usage | Mitigé | Token JWT stocké en mémoire RAM uniquement (pas de persistance disque). Pas de stockage de mot de passe client. Expiration token 1 h (côté backend, synchronisé avec session). |
| **M2** | Inadequate Supply Chain Security | Mitigé | Dépendances déclarées dans `pubspec.yaml`. `flutter pub get` utilise pub.dev (registry officiel Dart). Pas de dépendances git non vérifiées. Dependabot activé pour alertes vulnérabilités (`flutter_dsfr` = paquet officiel). |
| **M3** | Insecure Authentication / Authorization | Mitigé | Authentification JWT Bearer (token signé HMAC-SHA256). Validation côté backend systématique (guards NestJS). Pas de réutilisation de token après logout. Expiration 1 h. Pas de refresh token implémenté (roadmap V1.1). |
| **M4** | Insufficient Input/Output Validation | Atténué | Validation côté backend obligatoire (DTOs NestJS). Côté mobile : validation de base (email regex, champs required). Affichage de données utilisateur via interpolation Dart (pas d'injection de code). |
| **M5** | Insecure Communication | Atténué | HTTP en développement (sur LAN de test, préliminaire). HTTPS obligatoire en production (certificat TLS backend). Pas de pinning certificat implémenté (roadmap V1.1). Aucun proxy d'interception détectable sans confiance utilisateur. |
| **M6** | Inadequate Privacy Controls | Couvert | Token en mémoire (perdu fermeture app). Pas de tracker tiers embarqué (Google Analytics, Firebase Analytics). Pas de partage de données avec services externes. Permissions Android/iOS minimales (`image_picker` seul demande Camera/Photos). |
| **M7** | Insufficient Binary Protections | Partiel | APK debug non obfusquée (dev). APK release : obfuscation Dart natif via `flutter build apk --release`. Pas de code natif (C/C++) exposant secrets. Reverse engineering possible mais URL backend seule n'est pas sensible. |
| **M8** | Security Misconfiguration | Mitigé | Configuration unifiée dans `lib/shared/api_service.dart`. Debug mode désactivé en release. Permissions Android/iOS restreintes au strict nécessaire. Pas de logs verbeux exposant tokens ou identifiants. |
| **M9** | Insecure Data Storage | Couvert | Token stocké en mémoire RAM → perte à la fermeture app. Pas de SharedPreferences / Secure Storage activés pour le token. Données affichées uniquement en RAM, pas persistées localement. |
| **M10** | Insufficient Cryptography | Couvert | JWT signé HMAC-SHA256 (symétrique, secret partagé via backend). Communication HTTPS en production. Pas de chiffrement local implémenté (aucun stockage local sensible). Hash SHA256 + salt bcrypt côté backend (passwords). |

---

## Matrice des risques (probabilité × impact)

Échelle : Faible (1) · Moyen (2) · Élevé (3). **Criticité = Probabilité × Impact**.

| # | Risque / vulnérabilité | Probabilité | Impact | Criticité | Action préventive | Action corrective |
|---|---|:---:|:---:|:---:|---|---|
| R1 | Vol de token JWT via XSS (si code JavaScript côté mobile, non-applicable Dart natif) | Très faible | Élevé | 1 | Dart natif → pas de XSS. Validation backend systématique. Expiration 1 h. | Rotation `AUTH_TOKEN_SECRET` backend invalide tous tokens |
| R2 | Attaque brute-force sur `/auth/login` | Moyen | Moyen | 4 | `ThrottlerGuard` 5 req/min côté backend. Politique mot de passe forte 12 chars + complexité. | Blocage IP temporaire, notification utilisateur |
| R3 | Reverse engineering APK (extraction URL backend) | Élevé | Faible | 2 | URL codée en dur ne contient aucun secret. Tous les secrets restent backend. Obfuscation release. | Non-critère (pas de secret mobile). Stratégie : ne jamais embarquer secrets. |
| R4 | Tap-jacking / clickjacking (UI injection) | Très faible | Moyen | 1 | DSFR composants officiels. Pas de WebView côté app. Pas de gestion d'intent non-sécurisée. | Audit intent schemes, vérifier StrictMode activé |
| R5 | Vol d'appareil avec session active | Moyen | Moyen | 4 | Token en mémoire → perdu à fermeture/redémarrage. Pas de SharedPreferences. | À la perte, utilisateur ne peut plus accéder. Pas de récupération token possible. |
| R6 | Logs verbeux exposant données utilisateur | Moyen | Moyen | 4 | Pas de `print()` / `debugPrint()` contenant tokens, emails, données perso en release. | Code review, audit logs, suppression données sensibles |
| R7 | Permissions Android/iOS excessives | Faible | Moyen | 2 | Déclarer uniquement `camera`, `photos` (image_picker), aucune permission réseau/localisation non-nécessaire. | Audit manifest, revue permissions store (Google Play / App Store) |
| R8 | Dépendance npm/pub vulnérable | Moyen | Moyen | 4 | `flutter pub outdated`, Dependabot activé, mise à jour 48 h. | Mise à jour dépendance ou recherche alternative |
| R9 | Faille côté API backend (renvoie données sensibles) | Moyen | Élevé | 6 | Mobile transmet requêtes telles quelles → validation backend systématique. Mobile ne valide pas données reçues. | Patch backend rapide, notification utilisateurs app |
| R10 | Session HTTP en clair (man-in-the-middle) | Moyen (si HTTP dev) | Élevé | 6 | HTTPS obligatoire production. Pinning certificat (roadmap V1.1). | Mise à jour app avec certificat nouveau, notification urgente |

> Les risques de criticité ≥ 4 sont traités en priorité et réévalués lors de la revue annuelle.

---

## Authentification et gestion de session

### Flux d'authentification

```
1. Utilisateur saisit email + mot de passe → écran login_page.dart
2. POST /auth/login → backend valide, retourne JWT
3. Token stocké dans ApiService.session (variable statique)
4. Chaque requête ajoute : Authorization: Bearer <token>
5. Backend valide le token → AuthGuard + RolesGuard
6. Réponse retournée → affichée sur l'écran
7. Logout → ApiService.session = null
8. À la fermeture app → token perdu (volatil)
```

### Token JWT

- **Format** : `base64url(userId:email:timestamp).signature` (HMAC-SHA256)
- **Expiration** : 1 h (alignée avec rapport de soutenance backend)
- **Stockage** : variable statique `ApiService.session`, non persistée
- **Transmission** : en-tête `Authorization: Bearer <token>`

### Refresh token — Roadmap V1.1

Actuellement : pas de refresh token implémenté. Une fois expiration 1 h atteinte, utilisateur doit se reconnecter.

**Future implémentation** :
- Backend émet deux tokens : `accessToken` (1 h) + `refreshToken` (7 j)
- À expiration access token, mobile appelle `POST /auth/refresh` avec refreshToken
- Nouveau accessToken émis sans reconnexion utilisateur

### Pas de stockage persistant

**Avantage sécurité** : 
- Token perdu à la fermeture app
- Vol d'appareil → token inaccessible (plus en mémoire)
- Pas de risque de fuite via SharedPreferences non-chiffré

**Inconvénient UX** :
- Utilisateur devra se reconnecter à chaque redémarrage app

---

## Conformité RGPD

### Données collectées

| Donnée | Finalité | Sensibilité | Base légale | Stockage |
|--------|----------|-------------|------------|----------|
| Adresse email | Authentification, affichage profil | Personnelle | Consentement | Backend BDD |
| Mot de passe (hashé) | Authentification | Personnelle | Consentement | Backend BDD (bcrypt) |
| Prénom, nom | Affichage profil, commentaires | Personnelle | Consentement | Backend BDD |
| Photo de profil | Affichage profil | Personnelle | Consentement | Backend BDD (multipart POST) |
| Messages privés | Messagerie interne | Très sensible | Consentement | Backend BDD |
| Commentaires publics | Discussion ressources | Personnelle | Consentement | Backend BDD |
| Préférences (ressources sauvegardées) | Fonctionnalité favori | Faible | Consentement | Backend BDD |

### Droits des utilisateurs

| Droit | Implémentation mobile | Responsabilité |
|---|---|---|
| Accès | `GET /utilisateurs/:id` (propre profil) | Backend retourne données utilisateur. Mobile affiche via `account_page.dart`. |
| Rectification | `PATCH /utilisateurs/:id` + upload photo | Utilisateur modifie profil → backend met à jour BDD |
| Suppression | `DELETE /utilisateurs/:id` | Bouton suppression compte → suppression en cascade backend (messages, favoris, etc.) |
| Portabilité | Non implémenté | À prévoir en V1.1 (export JSON) |
| Opposition | Non applicable | Pas de traitement automatisé (scoring, profilage) |

### Permissions Android / iOS déclarées

| Permission | Usage | Justification |
|---|---|---|
| `android.permission.INTERNET` | Appels API | Requis |
| `android.permission.CAMERA` | Via `image_picker` | Optionnel, upload photo profil |
| `android.permission.READ_EXTERNAL_STORAGE` | Via `image_picker` | Optionnel, sélection photo profil |
| (iOS) `NSCameraUsageDescription` | Via `image_picker` | Optionnel, upload photo profil |
| (iOS) `NSPhotoLibraryUsageDescription` | Via `image_picker` | Optionnel, sélection photo profil |

**Aucune permission non-justifiée** (pas de localisation, Bluetooth, SMS, etc.).

### Durée de conservation

Non définie actuellement — action requise en production :

- **Comptes inactifs > 2 ans** : suppression ou anonymisation recommandée
- **Messages privés** : conservation indéfinie (réviser légalement)
- **Commentaires supprimés** : suppression logique (soft delete si audit requis)
- **Données de profil** : tant que compte actif

### Transferts hors UE

Aucun transfert hors UE prévu. Infrastructure requise :

- Hébergement backend **France ou UE** (Scaleway, OVH recommandés)
- Pas de dépendance cloud tiers (Google Cloud, AWS US) sans clause RGPD UE

---

## Sécurité des communications

### HTTP vs HTTPS

| Environnement | Protocole | TLS obligatoire |
|---|---|---|
| Développement local / émulateur | HTTP | Non (LAN de test) |
| Test device physique (LAN) | HTTP | Non (réseau interne) |
| Production | HTTPS | Oui (certificat Let's Encrypt) |

**Configuration Android** (Info.plist iOS inclus dans repo) :

Pour développement, autoriser HTTP non-chiffré temporairement :

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<domain-config cleartextTrafficPermitted="true">
  <domain includeSubdomains="true">10.0.2.2</domain>  <!-- localhost émulateur -->
</domain-config>
```

**En production** : supprimer cette exemption, TLS obligatoire.

### Certificate Pinning — Roadmap V1.1

Actuellement : accepte tout certificat TLS valide (sans pinning).

**Future implémentation** :

```dart
import 'package:http/http.dart' as http;
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

// Valider uniquement le certificat de api.rr.gouv.fr
SecurityContext securityContext = SecurityContext.defaultContext;
// Charger le certificat public
```

**Avantage** : protège contre les certificats man-in-the-middle (attaque gouvernementale, proxy corporate).

---

## Dépendances

### Audit de sécurité

Exécuter régulièrement :

```bash
flutter pub outdated                    # Lister versions disponibles
flutter pub upgrade                     # Mettre à jour compatibles
```

Les dépendances critiques pour la sécurité :

| Package | Version actuelle | Vulnérabilités connues | Action |
|---------|---|---|---|
| `http` | `^1.6.0` | À auditer via pub.dev | Mise à jour hebdo recommandée |
| `image_picker` | `^1.1.2` | Vérifier via plugin registry | Mise à jour trimestrielle |
| `flutter_dsfr` | git (main) | Suivi équipe SIG | Synchroniser avec releases officielles |
| `intl` | `^0.20.2` | Pas de vulnérabilités connues | Maintenue |

### Dependabot

Activer les alertes sur GitHub (Settings → Code security → Dependabot alerts). Les PRs de mise à jour mineures sont mergées rapidement.

---

## Procédure de gestion de crise

### Étape 1 — Détection

- Utilisateur signale bug via GitHub Issues (label `security`)
- Crash rapporté par Firebase Crashlytics (roadmap V1.1)
- Scan de sécurité détecte vulnérabilité (npm audit / pub)
- Audit manuel découvre faille

### Étape 2 — Confinement

```bash
# Si faille critique côté API :
# 1. Révocation tokens actifs (rotation AUTH_TOKEN_SECRET backend)
# 2. Ou désactivation fonctionnalité via feature flag backend

# Si faille mobile (ex. injection, reverse engineering) :
# 1. Créer branche hotfix depuis main
git checkout main
git pull origin main
git checkout -b hotfix/security-issue
# 2. Appliquer correctif dans lib/
# 3. Version bump pubspec.yaml : version: x.y.z+n → x.y.(z+1)+(n+1)
```

### Étape 3 — Éradication

```bash
# Commit + push
git add .
git commit -m "hotfix(security): <description> — CVE-2026-xxxxx"
git push origin hotfix/security-issue

# Pull Request vers main (accélérée)
gh pr create --base main --title "hotfix(security): ..."

# Une fois mergée :
git checkout main
git pull

# Build APK signé (V1.1) et publier sur stores
flutter build apk --release --...
# Upload Google Play Console
# Upload App Store Connect (V1.1)

# Propager le correctif en aval (preprod et develop)
# pour éviter qu'il soit écrasé au prochain merge normal
git checkout preprod && git pull && git merge --no-ff origin/main && git push
git checkout develop && git pull && git merge --no-ff origin/preprod && git push
```

**Délai global** : code prêt en 4–24 h, mais utilisateurs reçoivent la version via le store en **24–72 h** (Google Play) ou **1–3 jours** (App Store).

### Étape 4 — Notification

- Email utilisateurs affectés si données personnelles compromises
- Issue GitHub fermée avec résolution
- Release notes mentionnent le correctif

### Étape 5 — Notification CNIL

En cas de violation de données personnelles impactant des utilisateurs :

- **Délai légal** : notification CNIL dans les **72 heures** suivant découverte
- **Portail** : [https://notifications.cnil.fr](https://notifications.cnil.fr)
- **Informations à fournir** :
  - Nature de la violation (injection, reverse engineering, etc.)
  - Catégories et nombre estimé de personnes affectées
  - Conséquences probables
  - Mesures correctives prises ou envisagées
  - Si risque élevé : notification aussi directe aux utilisateurs

---

## Considérations de déploiement

### Kill switch backend

En cas de faille critique impossible à corriger rapidement côté mobile, le backend peut "tuer" une fonctionnalité :

```typescript
// Backend NestJS exemple
@Get('ressources')
@UseGuards(AuthGuard)
async getResources() {
  if (process.env.DISABLE_RESSOURCES === 'true') {
    throw new HttpException('Feature temporarily disabled', 503);
  }
  // ... logique
}
```

**Utilisation** :

```bash
# .env.prod (backend)
DISABLE_RESSOURCES=true

# Redémarrer API
docker compose restart api
```

Les utilisateurs recevront une erreur 503 sans app update requis.

---

## Checklist de rotation des secrets

### Token d'authentification (backend)

**`AUTH_TOKEN_SECRET`** — Rotation **mensuelle minimum**, **immédiate** en cas de suspicion compromission.

```bash
# Générer nouveau secret
openssl rand -base64 64

# Mettre à jour .env.prod backend
# Redémarrer API (invalide tous tokens existants)
# Utilisateurs devront se reconnecter → acceptable pour app à haute valeur
```

### Keystore Android (V1.1)

**Rotation annuelle** ou sur compromission.

```bash
# Générer nouveau keystore
keytool -genkey -v -keystore ~/rr-new.jks ...

# Conserver l'ancien pour signer hotfix des versions anciennes
# GitHub Secrets : mettre à jour ANDROID_KEYSTORE_BASE64
```

### Certificat Apple Developer (V1.1)

Durée Apple : **1 an**. À renouveler avant expiration (notification Apple à J-30).

---

## Ressources externes

- [OWASP Mobile Top 10 (2024)](https://owasp.org/www-project-mobile-top-10/)
- [CNIL — Conformité RGPD](https://www.cnil.fr/fr/rgpd)
- [Notifications violations CNIL](https://notifications.cnil.fr)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Dart Security — HTTP](https://api.dart.dev/stable/3.11.0/dart-io/HttpClient-class.html)
- [Google Play — App Security & Privacy](https://support.google.com/googleplay/android-developer/answer/11787059)
- [App Store Review Guidelines — Security](https://developer.apple.com/app-store/review/guidelines/#security)
- Repo GitHub : [ressources-relationnelles-CESI-EFTEG/mobile](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile)
