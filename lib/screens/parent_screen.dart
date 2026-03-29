import 'package:flutter/material.dart';

class ParentDashboardScreen extends StatelessWidget {
  final Map<String,  dynamic> parentData;

  const ParentDashboardScreen({
    super.key,
    required this.parentData, // This will come from your API
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0), // Soft pink background
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: const Color(0xFF6A5ACD), // Blue-purple top bar
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome Section
            const Icon(
              Icons.child_care,
              size: 80,
              color: Colors.pinkAccent,
            ),
            const SizedBox(height: 10),
            Text(
              "Welcome, ${parentData['full_name'] ?? 'Parent'}!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5ACD),
              ),
            ),
            const SizedBox(height: 20),

            // Parent Info Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    infoRow("Full Name", parentData['full_name']),
                    const SizedBox(height: 10),
                    infoRow("Email", parentData['email']),
                    const SizedBox(height: 10),
                    infoRow("Address", parentData['address']),
                    const SizedBox(height: 10),
                    infoRow("Hospital", parentData['hospital']),
                    const SizedBox(height: 10),
                    infoRow("Phone", parentData['phone']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Register Child Button / Link
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO Navigate to Register Child screen
                  Navigator.pushNamed(context, '/register-child');
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Register Child",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5ACD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to show a row of info
  Widget infoRow(String label, String? value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF6A5ACD),
          ),
        ),
        Expanded(
          child: Text(
            value ?? "-",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}