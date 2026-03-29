import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required void Function(Locale locale) onLocaleChange});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await authService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Login", style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: emailController,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter email" : null,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter password" : null,
                      decoration: const InputDecoration(labelText: "Password"),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: login,
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}