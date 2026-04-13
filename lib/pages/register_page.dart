import 'package:flutter/material.dart';
import '../shared/api_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey     = GlobalKey<FormState>();
  final _prenomCtrl  = TextEditingController();
  final _nomCtrl     = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading      = false;
  String? _error;

  @override
  void dispose() {
    _prenomCtrl.dispose(); _nomCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.register(
        prenom: _prenomCtrl.text.trim(),
        nom: _nomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );
      if (!mounted) return;
      await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on ApiException catch (e) {
      setState(() => _error = e.isConflict
          ? 'Un compte existe déjà avec cet email.'
          : e.isBadRequest
              ? (e.message.isNotEmpty ? e.message : 'Formulaire invalide. Vérifie les champs.')
              : 'Erreur API (${e.statusCode}). Vérifie que le backend tourne.');
    } catch (_) {
      setState(() => _error = "Erreur inconnue pendant l'inscription.");
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
                const Text('Inscription à Ressources relationnelles',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A), height: 1.3)),
                const SizedBox(height: 12),
                const Text('Créez votre compte pour accéder à votre espace personnel, vos ressources et votre messagerie.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5)),
                const SizedBox(height: 24),
                const FCInfoBanner(text: 'Tous les champs sont obligatoires. Une fois votre compte créé, vous pourrez vous connecter avec vos identifiants.'),
                const SizedBox(height: 28),
                const Text('Informations du compte',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 20),

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Prénom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 6),
                    FCField(controller: _prenomCtrl,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatoire' : null),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Nom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 6),
                    FCField(controller: _nomCtrl,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatoire' : null),
                  ])),
                ]),
                const SizedBox(height: 20),

                const Text('Adresse e-mail', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                const Text('Format attendu : nom@domaine.fr', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                const SizedBox(height: 6),
                FCField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null),
                const SizedBox(height: 20),

                const Text('Mot de passe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                const Text('8 caractères minimum', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                const SizedBox(height: 6),
                FCField(controller: _passCtrl, obscure: true,
                    validator: (v) => v == null || v.length < 8 ? 'Minimum 8 caractères' : null),
                const SizedBox(height: 20),

                const Text('Confirmer le mot de passe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 6),
                FCField(controller: _confirmCtrl, obscure: true,
                    validator: (v) => v != _passCtrl.text ? 'Les mots de passe ne correspondent pas' : null),
                const SizedBox(height: 28),

                if (_error != null) ...[FCErrorBanner(text: _error!), const SizedBox(height: 16)],

                Row(children: [
                  FCPrimaryBtn(label: _loading ? 'Création...' : 'Créer un compte', onTap: _loading ? null : _register),
                  const SizedBox(width: 12),
                  FCOutlineBtn(label: "J'ai déjà un compte", onTap: () => Navigator.pop(context)),
                ]),
                const SizedBox(height: 24),

                const Text("En créant un compte, vous pourrez accéder à vos ressources personnelles et utiliser la messagerie.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.5)),
              ]),
            ),
          ),
        ),
      );
}