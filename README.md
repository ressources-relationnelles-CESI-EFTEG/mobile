# Ressources Relationnelles — Mobile

[![CI](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile/actions/workflows/ci.yml)
[![CodeQL](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile/actions/workflows/github-code-scanning/codeql/badge.svg?branch=main)](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile/actions/workflows/github-code-scanning/codeql)
[![Latest Release](https://img.shields.io/github/v/release/ressources-relationnelles-CESI-EFTEG/mobile?label=release&color=blue)](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile/releases)
[![Licence Ouverte 2.0](https://img.shields.io/badge/Licence-Ouverte_2.0_(Etalab)-000091)](./LICENSE)

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)
![DSFR](https://img.shields.io/badge/DSFR-flutter__dsfr-000091)

Application mobile Flutter de la plateforme **Ressources (Re)lationnelles**. Permet aux citoyens de consulter et partager des ressources liées aux relations (famille, couple, amitié, etc.), d'échanger via la messagerie interne et de gérer leur profil. Design System de l'État Français (DSFR via `flutter_dsfr`).

## Prérequis

- Flutter SDK (Dart `^3.11.0`)
- Android Studio (pour l'émulateur Android) ou Xcode (pour le simulateur iOS)
- Backend Ressources Relationnelles démarré sur le port 3001

## Installation

```bash
flutter pub get
```

## URL de l'API

L'URL de base est codée en dur dans `lib/shared/api_service.dart` (ligne 5) :

```dart
const String _base = 'http://10.0.2.2:3001';
```

`10.0.2.2` est l'alias réseau de l'émulateur Android vers `localhost` de la machine hôte. **À adapter selon la cible :**

| Cible | Valeur de `_base` |
|-------|-------------------|
| Émulateur Android | `http://10.0.2.2:3001` |
| Simulateur iOS | `http://127.0.0.1:3001` |
| Appareil physique (même réseau) | `http://<IP-machine-hôte>:3001` |

> **iOS** : le transport HTTP non sécurisé est bloqué par défaut. Pour tester en développement, ajouter dans `ios/Runner/Info.plist` :
> ```xml
> <key>NSAppTransportSecurity</key>
> <dict><key>NSAllowsArbitraryLoads</key><true/></dict>
> ```

Il n'y a pas de fichier `.env` ni de `--dart-define` pour l'instant.

## Démarrage

```bash
flutter run                # Lancer sur l'émulateur/simulateur connecté
flutter build apk          # Compiler en APK Android
flutter build ios          # Compiler pour iOS (macOS requis)
```

## Structure du projet

```
lib/
  main.dart               Point d'entrée — MaterialApp, 9 routes, initialRoute: '/login'
  core/
    app_theme.dart        Thème global
  pages/
    login_page.dart       Connexion
    register_page.dart    Inscription
    accueil.dart          Page d'accueil
    dashboard_page.dart   Tableau de bord (ressources, conversations)
    account_page.dart     Profil et compte
    ressources_page.dart  Liste des ressources
    mesressources_page.dart Ressources de l'utilisateur connecté
    add_ressource_page.dart Création d'une ressource
    messages_page.dart    Messagerie (conversations et messages)
  shared/
    api_service.dart      Client HTTP, session en mémoire, ApiException
    models.dart           Modèles de données
    components.dart       Composants réutilisables
    app_scaffold.dart     Scaffold commun avec navigation
assets/
  logo_etat.png
```

## Dépendances principales

| Package | Version | Usage |
|---------|---------|-------|
| `http` | `^1.6.0` | Client HTTP (appels API) |
| `image_picker` | `^1.1.2` | Sélection et upload de photo de profil |
| `intl` | `^0.20.2` | Formatage des dates |
| `flutter_dsfr` | git (`main`) | Composants DSFR |

## Authentification

- Connexion via `POST /auth/login`, inscription via `POST /auth/register`.
- Le token est stocké **en mémoire uniquement** (`ApiService.session` — variable statique). Il est perdu à la fermeture de l'application (pas de `shared_preferences` ni de `flutter_secure_storage`).
- `ApiService.logout()` remet `session` à `null`.

## Endpoints consommés

| Module | Méthode | Route |
|--------|---------|-------|
| Auth | POST | `/auth/login`, `/auth/register` |
| Utilisateurs | GET | `/utilisateurs/:id` |
| Utilisateurs | PATCH | `/utilisateurs/:id` |
| Utilisateurs | POST | `/utilisateurs/:id/photo` (multipart) |
| Utilisateurs | DELETE | `/utilisateurs/:id/photo` |
| Ressources | GET | `/ressources` (`?categorieId=`) |
| Ressources | GET | `/ressources/:id` |
| Ressources | GET | `/ressources/utilisateur/:id` |
| Ressources | POST | `/ressources` |
| Ressources | DELETE | `/ressources/:id` |
| Catégories | GET | `/categories` |
| Favoris | GET | `/favoris/utilisateur/:id` |
| Favoris | DELETE | `/favoris/:userId/:ressourceId` |
| Progressions | GET | `/progressions/utilisateur/:id` |
| Commentaires | GET | `/commentaires/ressource/:id` |
| Commentaires | POST | `/commentaires` |
| Messagerie | GET | `/messagerie/conversations/utilisateur/:id` |
| Messagerie | GET | `/messagerie/conversations/:id/messages` |
| Messagerie | POST | `/messagerie/conversations/:id/messages` |
| Messagerie | PATCH | `/messagerie/conversations/:id/lu/:idUtilisateur` |

## Fonctionnalités couvertes

- Authentification (connexion / inscription)
- Tableau de bord
- Consultation, création, suppression de ressources
- Mes ressources (liste personnelle)
- Catégories
- Favoris (lecture et suppression)
- Progressions (lecture)
- Commentaires (lecture et création)
- Messagerie (conversations, envoi de messages, marquage comme lu)
- Profil (modification, upload / suppression de photo)

## Fonctionnalités non couvertes (disponibles sur le web)

- Signalements
- Modération et administration
- Ajout de favori
- Création d'une conversation
- Gestion des tags
- Notifications push

## Plateformes

| Plateforme | Statut |
|-----------|--------|
| Android | Configuré (`applicationId = com.example.mobile`) |
| iOS | Configuré (voir note HTTP ci-dessus) |
| Web / Desktop | Non configuré |

## Tests

```bash
flutter test
```

> **Limitation connue** : `test/widget_test.dart` est le smoke test par défaut généré par `flutter create`. Il référence `MyApp` qui n'existe pas dans ce projet (le point d'entrée est `App`) — le test ne compile pas en l'état. Il peut être supprimé ou corrigé.

## Comptes de démonstration

Mêmes comptes que le backend, mot de passe unique : **`Password123!`**

| Rôle | Email |
|------|-------|
| Super administrateur | superadmin@rr.local |
| Administrateur | admin@rr.local |
| Modérateur | moderateur@rr.local |
| Citoyen | citoyen@rr.local |

## Licence

Ce projet est distribué sous **[Licence Ouverte 2.0 (Etalab)](./LICENSE)** — la licence officielle de l'État français pour les codes sources et données publiques, conçue pour le secteur public et compatible avec les licences CC-BY, ODC-BY et OGL.

Vous pouvez librement réutiliser, modifier, redistribuer et exploiter ce code, y compris à des fins commerciales, sous la seule condition de mentionner la paternité (source : *Ressources Relationnelles — CESI EFTEG*) et la date de dernière mise à jour de l'information réutilisée.

Choix motivé par le contexte ministériel du projet : la Licence Ouverte est notamment retenue par `data.gouv.fr`, Etalab, beta.gouv.fr et le SocialGouv.
