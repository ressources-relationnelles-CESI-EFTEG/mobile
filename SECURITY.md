# Security Policy

La sécurité de l'application mobile **Ressources Relationnelles** est prioritaire. Si vous découvrez une faille de sécurité (transport non chiffré, stockage non sécurisé d'identifiants, contournement d'authentification, manipulation de l'IPC, etc.), **ne créez pas d'issue publique** : utilisez le canal privé suivant.

## Signaler une vulnérabilité

### Procédure de signalement

1. Ouvrir un **Security Advisory privé** :
   [https://github.com/ressources-relationnelles-CESI-EFTEG/mobile/security/advisories/new](https://github.com/ressources-relationnelles-CESI-EFTEG/mobile/security/advisories/new)
2. Décrire :
   - Le type de vulnérabilité (transport HTTP en clair, fuite via logs, stockage du token non chiffré, mauvaise gestion des permissions Android/iOS, etc.)
   - La plateforme et la version (Android API XX / iOS XX)
   - Les étapes de reproduction
   - L'impact estimé (utilisateur, modérateur, administrateur)

### Délais de réponse

| Sévérité | Première réponse | Correctif visé |
|----------|------------------|----------------|
| Critique (vol de session, exécution de code, fuite massive de données utilisateur) | 24 h | 72 h (release hotfix store) |
| Élevée | 3 jours | 2 semaines |
| Modérée / faible | 1 semaine | Prochaine release |

> **Note** : un correctif côté code peut être prêt en quelques heures, mais le délai de validation Google Play / Apple App Store (24 à 72 h) s'ajoute au délai de mise à disposition réelle aux utilisateurs.

### Versions supportées

Seule la dernière version publiée sur les stores reçoit des correctifs de sécurité. Les anciennes versions doivent être mises à jour par l'utilisateur.

### Politique de divulgation

Nous suivons une **divulgation coordonnée** : la faille n'est rendue publique qu'après mise à disposition d'un correctif sur les stores (Google Play, App Store). Le déclarant est crédité dans l'avis publié, sauf demande contraire.

### Périmètre

Sont concernés :
- Le code Flutter / Dart du dossier `lib/`
- Les configurations Android (`android/`) et iOS (`ios/`)
- La gestion du token d'authentification, du stockage local et des appels API

Le backend (API) est traité dans le repo [backend](https://github.com/ressources-relationnelles-CESI-EFTEG/backend) — sa propre policy de sécurité s'y applique.
