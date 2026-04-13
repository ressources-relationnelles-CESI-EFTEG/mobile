import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── CONFIG ───────────────────────────────────────────────────────────────────
// Émulateur Android  → 10.0.2.2:3001
// Simulateur iOS/web → 127.0.0.1:3001
// Vrai appareil      → IP de ta machine ex: 192.168.1.XX:3001
const String _base = 'http://10.0.2.2:3001';

// ─── SESSION ──────────────────────────────────────────────────────────────────
class UserSession {
  final String accessToken;
  final int id;
  final String? firstname;
  final String? lastname;
  final String email;
  final String role;

  const UserSession({
    required this.accessToken,
    required this.id,
    this.firstname,
    this.lastname,
    required this.email,
    required this.role,
  });

  String get fullName => '${firstname ?? ''} ${lastname != null ? '${lastname![0]}.' : ''}'.trim();

  // Réponse login: { accessToken, refreshToken, user: { id, firstname, lastname, email, role } }
  factory UserSession.fromLogin(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return UserSession(
      accessToken: json['accessToken'],
      id: user['id'],
      firstname: user['firstname'],
      lastname: user['lastname'],
      email: user['email'],
      role: user['role'],
    );
  }
}

// ─── SERVICE ──────────────────────────────────────────────────────────────────
class ApiService {
  static UserSession? session;
  static bool get isLoggedIn => session != null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (session != null) 'Authorization': 'Bearer ${session!.accessToken}',
      };

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════════════════════

  /// POST /auth/login
  /// Body: { email, password }
  static Future<UserSession> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _check(res, '/auth/login');
    session = UserSession.fromLogin(jsonDecode(res.body));
    return session!;
  }

  /// POST /auth/register
  /// Body: { prenom, nom, email, password, repeatPassword }
  static Future<void> register({
    required String prenom,
    required String nom,
    required String email,
    required String password, 
    required String confirmPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstname': prenom,
        'lastname': nom,
        'email': email,
        'password': password,
        'confirmPassword': password,
      }),
    );
    _check(res, '/auth/register');
  }

  static void logout() => session = null;

  // ══════════════════════════════════════════════════════════════════════════
  // UTILISATEURS
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /utilisateurs/:id
  static Future<Map<String, dynamic>> fetchUtilisateur(int id) async {
    final res = await http.get(Uri.parse('$_base/utilisateurs/$id'), headers: _headers);
    _check(res, '/utilisateurs/$id');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PATCH /utilisateurs/:id
  static Future<Map<String, dynamic>> updateUtilisateur(int id, Map<String, dynamic> data) async {
    final res = await http.patch(Uri.parse('$_base/utilisateurs/$id'), headers: _headers, body: jsonEncode(data));
    _check(res, '/utilisateurs/$id PATCH');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RESSOURCES
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /ressources
  static Future<List<Map<String, dynamic>>> fetchRessources({int? categorieId}) async {
    final uri = Uri.parse('$_base/ressources').replace(
      queryParameters: categorieId != null ? {'categorieId': categorieId.toString()} : null,
    );
    final res = await http.get(uri, headers: _headers);
    _check(res, '/ressources');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  /// GET /ressources/utilisateur/:id
  static Future<List<Map<String, dynamic>>> fetchRessourcesUtilisateur(int id) async {
    final res = await http.get(Uri.parse('$_base/ressources/utilisateur/$id'), headers: _headers);
    _check(res, '/ressources/utilisateur/$id');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  /// POST /ressources
  static Future<Map<String, dynamic>> createRessource(Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$_base/ressources'), headers: _headers, body: jsonEncode(data));
    _check(res, '/ressources POST');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// DELETE /ressources/:id
  static Future<void> deleteRessource(int id) async {
    final res = await http.delete(Uri.parse('$_base/ressources/$id'), headers: _headers);
    _check(res, '/ressources/$id DELETE');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATÉGORIES
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /categories
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final res = await http.get(Uri.parse('$_base/categories'), headers: _headers);
    _check(res, '/categories');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FAVORIS
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /favoris/utilisateur/:id
  static Future<List<Map<String, dynamic>>> fetchFavoris(int id) async {
    final res = await http.get(Uri.parse('$_base/favoris/utilisateur/$id'), headers: _headers);
    _check(res, '/favoris/utilisateur/$id');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  /// DELETE /favoris/:userId/:ressourceId
  static Future<void> removeFavori(int userId, int ressourceId) async {
    final res = await http.delete(Uri.parse('$_base/favoris/$userId/$ressourceId'), headers: _headers);
    _check(res, '/favoris DELETE');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROGRESSIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /progressions/utilisateur/:id
  static Future<List<Map<String, dynamic>>> fetchProgressions(int id) async {
    final res = await http.get(Uri.parse('$_base/progressions/utilisateur/$id'), headers: _headers);
    _check(res, '/progressions/utilisateur/$id');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGERIE
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /messagerie/conversations/utilisateur/:id
  static Future<List<Map<String, dynamic>>> fetchConversations(int id) async {
    final res = await http.get(Uri.parse('$_base/messagerie/conversations/utilisateur/$id'), headers: _headers);
    _check(res, '/messagerie/conversations/utilisateur/$id');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  /// GET /messagerie/conversations/:id/messages
  static Future<List<Map<String, dynamic>>> fetchMessages(int idConversation) async {
    final res = await http.get(Uri.parse('$_base/messagerie/conversations/$idConversation/messages'), headers: _headers);
    _check(res, '/messagerie/conversations/$idConversation/messages');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  /// POST /messagerie/conversations/:id/messages
  /// Body: { idUtilisateur, contenu }
  static Future<Map<String, dynamic>> sendMessage({
    required int idConversation,
    required int idUtilisateur,
    required String contenu,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/messagerie/conversations/$idConversation/messages'),
      headers: _headers,
      body: jsonEncode({'idUtilisateur': idUtilisateur, 'contenu': contenu}),
    );
    _check(res, '/messagerie/conversations/$idConversation/messages POST');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PATCH /messagerie/conversations/:id/lu/:userId
  static Future<void> markAsRead(int idConversation, int idUtilisateur) async {
    final res = await http.patch(
      Uri.parse('$_base/messagerie/conversations/$idConversation/lu/$idUtilisateur'),
      headers: _headers,
    );
    _check(res, '/messagerie/lu PATCH');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER
  // ══════════════════════════════════════════════════════════════════════════

  static void _check(http.Response res, String endpoint) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = res.body;
      try {
        final json = jsonDecode(res.body);
        final m = json['message'];
        message = m is List ? m.join(', ') : m?.toString() ?? res.body;
      } catch (_) {}
      throw ApiException(statusCode: res.statusCode, endpoint: endpoint, message: message);
    }
  }
}

// ─── EXCEPTION ────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String endpoint;
  final String message;

  const ApiException({required this.statusCode, required this.endpoint, required this.message});

  @override
  String toString() => 'ApiException [$statusCode] $endpoint: $message';

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound     => statusCode == 404;
  bool get isConflict     => statusCode == 409;
  bool get isBadRequest   => statusCode == 400;
} 