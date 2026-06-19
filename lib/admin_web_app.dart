
// NOTE: This is a separate Flutter Web App for Admin Dashboard
// It should be in a separate project: admin_dashboard_web/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Admin Dashboard Web App
// This is a SEPARATE project from the mobile app
// Deploy to: https://your-admin-panel.web.app

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard - أستاذ النحو العربي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        useMaterial3: true,
      ),
      home: const AdminLoginScreen(),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.user != null) {
        // Verify admin status via Cloud Function (secure)
        final callable = FirebaseFunctions.instance.httpsCallable('verifyAdmin');
        final response = await callable.call({'uid': result.user!.uid});

        if (response.data['isAdmin'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminWebDashboard()),
          );
        } else {
          await FirebaseAuth.instance.signOut();
          _showError('Unauthorized: Admin access only');
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 64, color: Color(0xFF6C63FF)),
              const SizedBox(height: 24),
              const Text(
                'Admin Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminWebDashboard extends StatelessWidget {
  const AdminWebDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: 0,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.question_answer),
                label: Text('Questions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
          ),

          // Main content
          const Expanded(
            child: Center(
              child: Text('Admin Dashboard Content'),
            ),
          ),
        ],
      ),
    );
  }
}
