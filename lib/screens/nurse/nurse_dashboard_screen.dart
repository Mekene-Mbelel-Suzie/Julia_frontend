import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../nurse/nurse_children_screen.dart';
import '../nurse/nurse_dashboard_records_screen.dart';

class NurseDashboardScreen extends StatefulWidget {
  final AppUser user;

  const NurseDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends State<NurseDashboardScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _overviewPage(),
      const NurseChildrenScreen(),
      const NurseDashboardRecordsScreen(),
    ];

    final title = selectedIndex == 0
        ? 'Nurse Dashboard'
        : selectedIndex == 1
        ? 'Hospital Children'
        : 'Vaccination Queue';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await AuthService().logout();
              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.child_care_outlined),
                selectedIcon: Icon(Icons.child_care),
                label: Text('Children'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: Text('Queue'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }

  Widget _overviewPage() {
    final user = widget.user;
    final hospitalName = user.hospital?['name'] ?? 'No hospital';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 450,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user.fullName}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Review children in your hospital and update vaccine administration records.',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Role: ${user.role}'),
                        Text('Email: ${user.email}'),
                        Text('Hospital: $hospitalName'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            child: ListTile(
              leading: Icon(Icons.medical_services_outlined),
              title: Text('Children Workspace'),
              subtitle: Text(
                'Open hospital children and update vaccination records.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.assignment_turned_in_outlined),
              title: Text('Vaccination Queue'),
              subtitle: Text(
                'Use the queue to quickly manage due today, overdue, given, and missed vaccinations.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}