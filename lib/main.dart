import 'package:flutter/material.dart';
import 'auth_pages.dart';
import 'dashboard.dart';

void main() => runApp(const TaskMasterApp());

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? MainDashboard(onLogout: () => setState(() => _isLoggedIn = false))
        : LoginPage(onLogin: () => setState(() => _isLoggedIn = true));
  }
}
