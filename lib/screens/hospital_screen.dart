import 'package:flutter/material.dart';

class HospitalScreen extends StatelessWidget {
  final Map<String, dynamic> hospitalData;
  const HospitalScreen({super.key, required this.hospitalData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Dashboard"), backgroundColor: const Color(0xFF1E88E5)),
      body: Center(child: Text("Welcome Hospital 🏥\n${hospitalData['name'] ?? ''}")),
    );
  }
}