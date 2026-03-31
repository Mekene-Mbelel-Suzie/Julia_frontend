import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import 'nurse_dashboard_screen.dart';
import 'parent_dashboard_screen.dart';
import 'super_admin_dashboard_screen.dart';

class DashboardRouter extends StatelessWidget {
  final AppUser user;

  const DashboardRouter({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    switch (user.role) {
      case 'parent':
        return ParentDashboardScreen(user: user);
      case 'nurse':
      case 'hospital_admin':
        return NurseDashboardScreen(user: user);
      case 'super_admin':
        return SuperAdminDashboardScreen(user: user);
      default:
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: Center(
            child: Text('Unsupported role: ${user.role}'),
          ),
        );
    }
  }
}