// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart' as auth_service; // 🔹 alias to avoid name conflicts
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final Function(Locale)? onLocaleChange; // optional

  const SignupScreen({super.key, this.onLocaleChange});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();

  // 🔹 Use the alias here to avoid conflicts
  final authService = auth_service.AuthService();

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await authService.signup(
        fullName: fullNameController.text,
        phoneNumber: phoneController.text,
        address: addressController.text,
        email: emailController.text,
        password: passwordController.text,
        hospitalName: hospitalController.text,
      );

      if (response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Signup successful!")));
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.child_care, size: 80, color: Color(0xFFF48FB1)),
                    const SizedBox(height: 20),

                    // Full Name
                    TextFormField(
                      controller: fullNameController,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter full name" : null,
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),

                    const SizedBox(height: 10),

                    // Phone
                    TextFormField(
                      controller: phoneController,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter phone" : null,
                      decoration: const InputDecoration(labelText: "Phone Number"),
                    ),

                    const SizedBox(height: 10),

                    // Address
                    TextFormField(
                      controller: addressController,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter address" : null,
                      decoration: const InputDecoration(labelText: "Address"),
                    ),

                    const SizedBox(height: 10),

                    // Hospital
                    TextFormField(
                      controller: hospitalController,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter hospital" : null,
                      decoration: const InputDecoration(labelText: "Hospital Name"),
                    ),

                    const SizedBox(height: 10),

                    // Email
                    TextFormField(
                      controller: emailController,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter email" : null,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),

                    const SizedBox(height: 10),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter password" : null,
                      decoration: const InputDecoration(labelText: "Password"),
                    ),

                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Signup",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Color(0xFFF48FB1)),
                      ),
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