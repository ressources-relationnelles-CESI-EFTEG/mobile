// ─── UTILISATEUR ─────────────────────────────────────────────────────────────
class UserModel {
  final String firstName;       // [BDD] users.first_name
  final String lastName;        // [BDD] users.last_name
  final String? avatarUrl;      // [BDD] users.avatar_url
  final DateTime lastLogin;     // [BDD] users.last_login_at

  const UserModel({
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.lastLogin,
  });

  String get fullName => '$firstName ${lastName[0]}.';

  static UserModel placeholder() => UserModel(
        firstName: 'Marie',
        lastName: 'Dupont',
        avatarUrl: null,
        lastLogin: DateTime.now(),
      );
}

// ─── MENTOR ───────────────────────────────────────────────────────────────────
class MentorModel {
  final String id;              // [BDD] mentors.id
  final String firstName;       // [BDD] mentors.first_name
  final String lastName;        // [BDD] mentors.last_name
  final String specialty;       // [BDD] mentors.specialty
  final String? avatarUrl;      // [BDD] mentors.avatar_url
  final double rating;          // [BDD] mentors.rating
  final int reviewCount;        // [BDD] mentors.review_count
  final String bio;             // [BDD] mentors.bio
  final List<String> modes;     // [BDD] mentors.modes
  final String? currentQuote;   // [BDD] relation user_mentor.last_message

  const MentorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    required this.modes,
    this.currentQuote,
  });

  String get fullName => '$firstName ${lastName[0]}.';

  static MentorModel placeholder() => const MentorModel(
        id: 'mentor_001',
        firstName: 'Jean',
        lastName: 'Petit',
        specialty: 'Expert en communication',
        rating: 4.5,
        reviewCount: 12,
        bio: 'Nous travaillons ensemble sur vos objectifs relationnels depuis 3 mois.',
        modes: ['Visio', 'Chat'],
        currentQuote: '"Nous travaillons ensemble sur vos objectifs relationnels depuis 3 mois."',
      );
}

// ─── OBJECTIF ────────────────────────────────────────────────────────────────
class GoalModel {
  final String id;              // [BDD] goals.id
  final String title;           // [BDD] goals.title
  final double progressPercent; // [BDD] goals.progress
  final int sessionsCompleted;  // [BDD] sessions WHERE status = 'done'
  final int sessionsTotal;      // [BDD] goals.sessions_total

  const GoalModel({
    required this.id,
    required this.title,
    required this.progressPercent,
    required this.sessionsCompleted,
    required this.sessionsTotal,
  });

  static GoalModel placeholder() => const GoalModel(
        id: 'goal_001',
        title: 'Confiance en soi',
        progressPercent: 0.65,
        sessionsCompleted: 4,
        sessionsTotal: 6,
      );
}

// ─── RESSOURCE RECOMMANDÉE ────────────────────────────────────────────────────
class ResourceModel {
  final String id;              // [BDD] resources.id
  final String title;           // [BDD] resources.title
  final String type;            // [BDD] resources.type (pdf, video, article)
  final String meta;            // [BDD] resources.duration / read_time
  final String? url;            // [BDD] resources.url

  const ResourceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.meta,
    this.url,
  });

  static List<ResourceModel> placeholders() => const [
        ResourceModel(id: 'res_001', title: 'Guide : Gérer les conflits', type: 'pdf', meta: 'PDF • 15 min de lecture'),
        ResourceModel(id: 'res_002', title: 'Vidéo : Techniques d\'écoute active', type: 'video', meta: '12 min • Niveau débutant'),
      ];
}

// ─── SESSION ─────────────────────────────────────────────────────────────────
class SessionModel {
  final String id;              // [BDD] sessions.id
  final String title;           // [BDD] sessions.title
  final DateTime date;          // [BDD] sessions.scheduled_at
  final String duration;        // [BDD] sessions.duration_minutes
  final String location;        // [BDD] sessions.location
  final bool isConfirmed;       // [BDD] sessions.confirmed_by_user

  const SessionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.location,
    required this.isConfirmed,
  });

  static SessionModel placeholder() => SessionModel(
        id: 'session_001',
        title: 'Atelier : Gestion du stress en entretien',
        date: DateTime.now().add(const Duration(days: 1)),
        duration: '1h30',
        location: 'En ligne (lien Zoom envoyé par email)',
        isConfirmed: false,
      );
}

// ─── MESSAGE ─────────────────────────────────────────────────────────────────
class MessageModel {
  final String id;              // [BDD] messages.id
  final String senderName;      // [BDD] users.first_name + last_name
  final String senderType;      // [BDD] 'mentor' | 'support' | 'user'
  final DateTime sentAt;        // [BDD] messages.created_at
  final String preview;         // [BDD] messages.body
  final bool isRead;            // [BDD] messages.read_at IS NULL

  const MessageModel({
    required this.id,
    required this.senderName,
    required this.senderType,
    required this.sentAt,
    required this.preview,
    required this.isRead,
  });

  static List<MessageModel> placeholders() => [
        MessageModel(
          id: 'msg_001',
          senderName: 'Jean P.',
          senderType: 'mentor',
          sentAt: DateTime.now().subtract(const Duration(hours: 20)),
          preview: 'J\'ai ajouté de nouvelles ressources sur la gestion du stress que je pense pourraient t\'aider.',
          isRead: false,
        ),
        MessageModel(
          id: 'msg_002',
          senderName: 'Support (RE)SOURCES',
          senderType: 'support',
          sentAt: DateTime.now().subtract(const Duration(days: 2)),
          preview: 'Votre feedback sur la dernière séance a bien été enregistré. Merci pour votre participation !',
          isRead: true,
        ),
      ];
}

// ─── DOCUMENT ────────────────────────────────────────────────────────────────
class DocumentModel {
  final String id;              // [BDD] documents.id
  final String title;           // [BDD] documents.title
  final String fileType;        // [BDD] documents.file_type (PDF, DOCX, PPTX...)
  final int sizeKb;             // [BDD] documents.size_kb
  final bool isFavorite;        // [BDD] documents.is_favorite
  final bool isShared;          // [BDD] documents.is_shared
  final String? sharedBy;       // [BDD] users.first_name + last_name (si partagé)
  final String? url;            // [BDD] documents.storage_url

  const DocumentModel({
    required this.id,
    required this.title,
    required this.fileType,
    required this.sizeKb,
    required this.isFavorite,
    required this.isShared,
    this.sharedBy,
    this.url,
  });

  String get sizeLabel {
    if (sizeKb >= 1024) return '${(sizeKb / 1024).toStringAsFixed(1)} MB';
    return '$sizeKb KB';
  }

  String get meta => '$fileType • $sizeLabel';

  // [BDD] fetch documents WHERE owner_id = currentUser.id AND is_shared = false
  static List<DocumentModel> myDocumentsPlaceholders() => const [
        DocumentModel(id: 'doc_001', title: 'Mon CV', fileType: 'PDF', sizeKb: 210, isFavorite: false, isShared: false),
        DocumentModel(id: 'doc_002', title: 'Attestation de formation', fileType: 'PDF', sizeKb: 85, isFavorite: false, isShared: false),
        DocumentModel(id: 'doc_003', title: 'Notes personnelles', fileType: 'DOCX', sizeKb: 45, isFavorite: true, isShared: false),
      ];

  // [BDD] fetch documents WHERE shared_with = currentUser.id
  static List<DocumentModel> sharedDocumentsPlaceholders() => const [
        DocumentModel(id: 'doc_004', title: 'Guide de communication', fileType: 'PDF', sizeKb: 210, isFavorite: false, isShared: true, sharedBy: 'Jean P.'),
        DocumentModel(id: 'doc_005', title: 'Exercices confiance', fileType: 'PDF', sizeKb: 150, isFavorite: true, isShared: true, sharedBy: 'Sophie M.'),
        DocumentModel(id: 'doc_006', title: 'Présentation', fileType: 'PPTX', sizeKb: 1200, isFavorite: false, isShared: true, sharedBy: 'Thomas L.'),
      ];
}

// ─── CONVERSATION ────────────────────────────────────────────────────────────
class ConversationModel {
  final String id;              // [BDD] conversations.id
  final String contactName;     // [BDD] users.first_name + last_name
  final String contactType;     // [BDD] 'mentor' | 'support' | 'user'
  final String? avatarUrl;      // [BDD] users.avatar_url
  final String lastMessage;     // [BDD] messages.body (dernier)
  final DateTime lastMessageAt; // [BDD] messages.created_at (dernier)
  final bool isOnline;          // [BDD] users.is_online
  final int unreadCount;        // [BDD] COUNT messages WHERE read_at IS NULL

  const ConversationModel({
    required this.id,
    required this.contactName,
    required this.contactType,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.isOnline,
    required this.unreadCount,
  });

  static List<ConversationModel> placeholders() => [
        ConversationModel(
          id: 'conv_001', contactName: 'Jean P.', contactType: 'mentor',
          lastMessage: 'D\'accord, nous en parlerons lors de notre prochaine séance.',
          lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
          isOnline: true, unreadCount: 0,
        ),
        ConversationModel(
          id: 'conv_002', contactName: 'Sophie M.', contactType: 'mentor',
          lastMessage: 'Avez-vous eu le temps de regarder les ressources ?',
          lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
          isOnline: false, unreadCount: 2,
        ),
        ConversationModel(
          id: 'conv_003', contactName: 'Support (RE)SOURCES', contactType: 'support',
          lastMessage: 'Votre feedback a été enregistré',
          lastMessageAt: DateTime(2025, 12, 4),
          isOnline: false, unreadCount: 0,
        ),
      ];
}

// ─── MESSAGE DE CHAT ─────────────────────────────────────────────────────────
class ChatMessageModel {
  final String id;              // [BDD] messages.id
  final String conversationId;  // [BDD] messages.conversation_id
  final String senderId;        // [BDD] messages.sender_id
  final bool isMe;              // senderId == currentUser.id
  final String body;            // [BDD] messages.body
  final DateTime sentAt;        // [BDD] messages.created_at

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.isMe,
    required this.body,
    required this.sentAt,
  });

  static List<ChatMessageModel> placeholders(String convId) => [
        ChatMessageModel(
          id: 'cmsg_001', conversationId: convId, senderId: 'mentor_001', isMe: false,
          body: 'Bonjour Marie, comment s\'est passé ton entretien ?',
          sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 18)),
        ),
        ChatMessageModel(
          id: 'cmsg_002', conversationId: convId, senderId: 'user_001', isMe: true,
          body: 'Bonjour Jean, ça s\'est bien passé mais j\'étais très stressée',
          sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
        ),
        ChatMessageModel(
          id: 'cmsg_003', conversationId: convId, senderId: 'mentor_001', isMe: false,
          body: 'C\'est normal pour un premier entretien. Tu veux qu\'on en parle en visio ?',
          sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 13)),
        ),
        ChatMessageModel(
          id: 'cmsg_004', conversationId: convId, senderId: 'user_001', isMe: true,
          body: 'Avec plaisir, quand seriez-vous disponible ?',
          sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 11)),
        ),
      ];
}