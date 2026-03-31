import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../parents/parent_children_screen.dart';
import 'base_dashboard_scaffold.dart';

class ParentDashboardScreen extends StatefulWidget {
  final AppUser user;

  const ParentDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _idx = 0;

  static const _nav = [
    (Icons.grid_view_rounded, Icons.grid_view_rounded, 'Overview'),
    (Icons.child_care_outlined, Icons.child_care_rounded, 'Children'),
  ];

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _overview(),
      const ParentChildrenScreen(),
    ];

    return DashboardShell(
      role: 'Parent',
      accentColor: const Color(0xFFF57C00),
      user: widget.user,
      navItems: _nav,
      selectedIndex: _idx,
      onNavTap: (i) => setState(() => _idx = i),
      onRefresh: () => setState(() {}),
      onLogout: _logout,
      child: pages[_idx],
    );
  }

  Widget _overview() {
    final u = widget.user;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeBanner(
            user: u,
            accent: const Color(0xFFF57C00),
            subtitle:
            'Track your children, follow vaccination plans, and never miss an upcoming dose.',
          ),
          const SizedBox(height: 28),
          _sectionLabel('Profile Details', isLight),
          const SizedBox(height: 12),
          _ProfileTable(user: u, isLight: isLight),
          const SizedBox(height: 24),
          _sectionLabel('Quick Actions', isLight),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionCard(
                icon: Icons.child_care_rounded,
                label: 'My Children',
                description: 'Add a child and generate a vaccination plan.',
                color: const Color(0xFFF57C00),
                onTap: () => setState(() => _idx = 1),
                isLight: isLight,
              ),
              _ActionCard(
                icon: Icons.vaccines_rounded,
                label: 'Vaccination Plans',
                description: 'Track upcoming and past doses for each child.',
                color: const Color(0xFF0288D1),
                onTap: () => setState(() => _idx = 1),
                isLight: isLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileTable extends StatelessWidget {
  final AppUser user;
  final bool isLight;

  const _ProfileTable({
    required this.user,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Full Name', user.fullName),
      ('Email', user.email),
      ('Phone', user.phone ?? '—'),
      ('Address', user.parentProfile?['address'] ?? '—'),
      ('Hospital', user.hospital?['name'] ?? '—'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(160),
          1: FlexColumnWidth(),
        },
        children: rows
            .asMap()
            .entries
            .map(
              (e) => TableRow(
            decoration: BoxDecoration(
              border: e.key == 0
                  ? null
                  : Border(
                top: BorderSide(
                  color: isLight
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF1E2535),
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                child: Text(
                  e.value.$1,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isLight
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF4A5568),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                child: Text(
                  e.value.$2,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isLight
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ],
          ),
        )
            .toList(),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final bool isLight;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
    required this.isLight,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 240,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.isLight ? Colors.white : const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.color.withOpacity(0.4)
                  : (widget.isLight
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF252B3B)),
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? widget.color.withOpacity(0.12)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: widget.isLight
                            ? const Color(0xFF0D1B2A)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sectionLabel(String text, bool isLight) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: isLight
          ? const Color(0xFF94A3B8)
          : const Color(0xFF4A5568),
    ),
  );
}