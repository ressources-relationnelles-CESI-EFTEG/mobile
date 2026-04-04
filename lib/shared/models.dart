// ─── SESSION UTILISATEUR (après login) ───────────────────────────────────────
// Voir ApiService.session

// ─── MODÈLES POUR LES PAGES ───────────────────────────────────────────────────
// Ces modèles restent pour l'affichage dans les widgets
// Les données viennent maintenant du vrai backend via ApiService

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? description;
  final String? region;
  final String? telephone;
  final DateTime lastLogin;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.description,
    this.region,
    this.telephone,
    required this.lastLogin,
  });

  String get fullName => '$firstName ${lastName[0]}.';

  factory UserModel.fromJson(Map<String, dynamic> d) => UserModel(
        id: d['idUtilisateur'],
        firstName: d['prenom'] ?? '',
        lastName: d['nom'] ?? '',
        avatarUrl: d['photoProfil'],
        description: d['description'],
        region: d['region'],
        telephone: d['telephone'],
        lastLogin: d['dateCreation'] != null
            ? DateTime.parse(d['dateCreation'])
            : DateTime.now(),
      );

  static UserModel placeholder() => UserModel(
        id: 0,
        firstName: 'Marie',
        lastName: 'Dupont',
        lastLogin: DateTime.now(),
      );
}

class RessourceModel {
  final int id;
  final String titre;
  final String? description;
  final String contenu;
  final String? typeRessource;
  final String? niveauDifficulte;
  final String visibilite;
  final String statut;
  final String? lienPartage;
  final DateTime dateCreation;
  final Map<String, dynamic>? categorie;
  final Map<String, dynamic>? utilisateur;
  final List<dynamic> tags;

  const RessourceModel({
    required this.id,
    required this.titre,
    this.description,
    required this.contenu,
    this.typeRessource,
    this.niveauDifficulte,
    required this.visibilite,
    required this.statut,
    this.lienPartage,
    required this.dateCreation,
    this.categorie,
    this.utilisateur,
    this.tags = const [],
  });

  factory RessourceModel.fromJson(Map<String, dynamic> d) => RessourceModel(
        id: d['idRessource'],
        titre: d['titre'] ?? '',
        description: d['description'],
        contenu: d['contenu'] ?? '',
        typeRessource: d['typeRessource'],
        niveauDifficulte: d['niveauDifficulte'],
        visibilite: d['visibilite'] ?? 'privee',
        statut: d['statut'] ?? 'brouillon',
        lienPartage: d['lienPartage'],
        dateCreation: d['dateCreation'] != null
            ? DateTime.parse(d['dateCreation'])
            : DateTime.now(),
        categorie: d['categorie'] as Map<String, dynamic>?,
        utilisateur: d['utilisateur'] as Map<String, dynamic>?,
        tags: d['tags'] as List<dynamic>? ?? [],
      );

  String get typeLabel => switch (typeRessource?.toLowerCase()) {
        'video'    => 'Vidéo',
        'audio'    => 'Audio',
        'exercice' => 'Exercice',
        'activite' => 'Activité',
        'jeu'      => 'Jeu',
        _          => 'Article',
      };
}

class ConversationModel {
  final int id;
  final DateTime dateCreation;
  final List<dynamic> participants;
  final Map<String, dynamic>? dernierMessage;

  const ConversationModel({
    required this.id,
    required this.dateCreation,
    required this.participants,
    this.dernierMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> d) => ConversationModel(
        id: d['idConversation'],
        dateCreation: DateTime.parse(d['dateCreation']),
        participants: d['participants'] as List<dynamic>? ?? [],
        dernierMessage: d['dernierMessage'] as Map<String, dynamic>?,
      );

  String contactName(int myId) {
    final other = participants.firstWhere(
      (p) => (p['utilisateur']?['idUtilisateur'] ?? p['idUtilisateur']) != myId,
      orElse: () => participants.isNotEmpty ? participants.first : null,
    );
    if (other == null) return 'Inconnu';
    final u = other['utilisateur'] ?? other;
    return '${u['prenom'] ?? ''} ${u['nom'] ?? ''}'.trim();
  }

  String get lastMessagePreview =>
      dernierMessage?['contenu'] ?? 'Aucun message';

  DateTime get lastMessageAt => dernierMessage != null
      ? DateTime.parse(dernierMessage!['dateEnvoi'])
      : dateCreation;

  bool get hasUnread =>
      dernierMessage != null && dernierMessage!['lu'] == false;
}

class MessageModel {
  final int id;
  final int idConversation;
  final int idUtilisateur;
  final String contenu;
  final DateTime dateEnvoi;
  final bool lu;
  final Map<String, dynamic>? utilisateur;

  const MessageModel({
    required this.id,
    required this.idConversation,
    required this.idUtilisateur,
    required this.contenu,
    required this.dateEnvoi,
    required this.lu,
    this.utilisateur,
  });

  bool isMe(int myId) => idUtilisateur == myId;

  factory MessageModel.fromJson(Map<String, dynamic> d) => MessageModel(
        id: d['idMessage'],
        idConversation: d['idConversation'],
        idUtilisateur: d['idUtilisateur'],
        contenu: d['contenu'] ?? '',
        dateEnvoi: DateTime.parse(d['dateEnvoi']),
        lu: d['lu'] ?? false,
        utilisateur: d['utilisateur'] as Map<String, dynamic>?,
      );
}

class CategorieModel {
  final int id;
  final String nom;
  final String? description;
  final int? parentId;

  const CategorieModel({
    required this.id,
    required this.nom,
    this.description,
    this.parentId,
  });

  factory CategorieModel.fromJson(Map<String, dynamic> d) => CategorieModel(
        id: d['idCategorie'],
        nom: d['nom'] ?? '',
        description: d['description'],
        parentId: d['parentId'],
      );
}