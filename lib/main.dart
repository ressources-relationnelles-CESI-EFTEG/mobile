import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/account_page.dart';
import 'pages/messages_page.dart';
import 'pages/add_ressource_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '(RE)SOURCES RELATIONNELLES',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/login',
      routes: {
        '/login':         (_) => const LoginPage(),
        '/register':      (_) => const RegisterPage(),
        '/dashboard':     (_) => const DashboardPage(),
        '/account':       (_) => const AccountPage(),
        '/messages':      (_) => const MessagesPage(),
        '/add-ressource': (_) => const AddRessourcePage(),
      },
    );
  }
}