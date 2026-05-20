import 'package:flutter/material.dart';
import '../shared/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on ApiException catch (e) {
      setState(() => _error = e.isUnauthorized
          ? 'Identifiants invalides.'
          : 'Erreur API (${e.statusCode}). Vérifie que le backend tourne.');
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Logo + Titre ───────────────────────────────────────────
                Row(children: [
                  Image.asset('assets/logo_etat.png', height: 60),
                  const SizedBox(width: 20),
                  const Text('Ressources\nrelationnelles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      )),
                ]),
                const SizedBox(height: 24),

                const Text('Connexion à Ressources relationnelles',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A), height: 1.3)),
                const SizedBox(height: 12),
                const Text('Connectez-vous pour accéder à votre espace personnel.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5)),
                const SizedBox(height: 24),
                const FCInfoBanner(
                    text: "La connexion nécessite un compte existant. "
                        "Si vous n'avez pas encore de compte, vous pouvez vous inscrire."),
                const SizedBox(height: 28),
                const Text('Informations de connexion',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 20),
                const Text('Adresse e-mail',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                const Text('Format attendu : nom@domaine.fr',
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                const SizedBox(height: 6),
                FCField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Email invalide' : null,
                ),
                const SizedBox(height: 20),
                const Text('Mot de passe',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 6),
                FCField(
                  controller: _passCtrl,
                  obscure: true,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Mot de passe requis' : null,
                ),
                const SizedBox(height: 28),
                if (_error != null) ...[
                  FCErrorBanner(text: _error!),
                  const SizedBox(height: 16),
                ],
                Row(children: [
                  FCPrimaryBtn(
                    label: _loading ? 'Connexion...' : 'Se connecter',
                    onTap: _loading ? null : _login,
                  ),
                  const SizedBox(width: 12),
                  FCOutlineBtn(
                    label: 'Créer un compte',
                    onTap: () => Navigator.pushNamed(context, '/register'),
                  ),
                ]),
                const SizedBox(height: 24),
                const Text(
                    'En vous connectant, vous accédez à vos ressources personnelles.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.5)),
              ]),
            ),
          ),
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPOSANTS PARTAGÉS
// ══════════════════════════════════════════════════════════════════════════════

class FCInfoBanner extends StatelessWidget {
  final String text;
  const FCInfoBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0F8),
          border: Border.all(color: const Color(0xFF1C3177).withOpacity(0.4)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1C3177),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)),
            ),
            child: const Center(
              child: Text('i',
                  style: TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Information',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 6),
                Text(text,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333),
                        height: 1.5)),
              ]),
            ),
          ),
        ]),
      );
}

class FCErrorBanner extends StatelessWidget {
  final String text;
  const FCErrorBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          border: Border.all(color: const Color(0xFFFCA5A5)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: Colors.red, height: 1.4)),
          ),
        ]),
      );
}

class FCField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const FCField({
    super.key,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFFF0F0F0),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1A1A1A), width: 1.5)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1A1A1A), width: 1.5)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1C3177), width: 2)),
          errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5)),
          focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2)),
        ),
      );
}

class FCPrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const FCPrimaryBtn({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C3177),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );
}

class FCOutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const FCOutlineBtn({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1C3177),
          side: const BorderSide(color: Color(0xFF1C3177), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );
}