import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../nurse/nurse_children_screen.dart';
import '../nurse/nurse_dashboard_records_screen.dart';
import 'base_dashboard_scaffold.dart';

class NurseDashboardScreen extends StatefulWidget {
  final AppUser user;
  const NurseDashboardScreen({super.key, required this.user});

  @override
  State<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends State<NurseDashboardScreen> {
  int _idx = 0;

  static const _nav = [
    (Icons.grid_view_rounded, Icons.grid_view_rounded, 'Overview'),
    (Icons.child_care_outlined, Icons.child_care_rounded, 'Children'),
    (Icons.assignment_outlined, Icons.assignment_rounded, 'Queue'),
  ];

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_overview(), const NurseChildrenScreen(), const NurseDashboardRecordsScreen()];
    return DashboardShell(
      role: 'Nurse', accentColor: const Color(0xFF00695C), user: widget.user,
      navItems: _nav, selectedIndex: _idx, onNavTap: (i) => setState(() => _idx = i),
      onRefresh: () => setState(() {}), onLogout: _logout, child: pages[_idx],
    );
  }

  Widget _overview() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        WelcomeBanner(user: widget.user, accent: const Color(0xFF00695C), subtitle: 'Review hospital children, manage due vaccinations, and update records efficiently.'),
        const SizedBox(height: 28),
        Wrap(spacing: 14, runSpacing: 14, children: [
          _QuickNav(icon: Icons.child_care_rounded, label: 'Hospital Children', description: 'Browse and manage all children registered in your hospital.', color: const Color(0xFF00695C), onTap: () => setState(() => _idx = 1), isLight: isLight),
          _QuickNav(icon: Icons.assignment_turned_in_rounded, label: 'Vaccination Queue', description: 'Handle due, overdue, given and missed vaccinations in batch.', color: const Color(0xFF1565C0), onTap: () => setState(() => _idx = 2), isLight: isLight),
        ]),
        const SizedBox(height: 28),
        Text('Workflow Guide', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
        const SizedBox(height: 12),
        _WorkflowTable(isLight: isLight),
      ]),
    );
  }
}

class _WorkflowTable extends StatelessWidget {
  final bool isLight;
  const _WorkflowTable({required this.isLight});

  static const _steps = [
    ('1', 'Open Children', 'Navigate to the Hospital Children tab', Icons.child_care_rounded),
    ('2', 'Select a Child', 'View their upcoming vaccination schedule', Icons.person_search_rounded),
    ('3', 'Update Records', 'Mark vaccines as given, missed, or pending', Icons.edit_note_rounded),
    ('4', 'Use the Queue', 'Batch-process all due vaccinations for the day', Icons.assignment_turned_in_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Table(
        columnWidths: const {0: FixedColumnWidth(52), 1: FixedColumnWidth(190), 2: FlexColumnWidth(), 3: FixedColumnWidth(44)},
        children: [
          TableRow(
            decoration: BoxDecoration(color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            children: ['#', 'Action', 'Description', ''].map((h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(h, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
            )).toList(),
          ),
          ..._steps.map((s) => TableRow(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E2535)))),
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Container(width: 22, height: 22, decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.12), shape: BoxShape.circle),
                      child: Center(child: Text(s.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00695C)))))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(s.$2, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: isLight ? const Color(0xFF0D1B2A) : Colors.white))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(s.$3, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  child: Icon(s.$4, size: 16, color: const Color(0xFF00695C).withOpacity(0.5))),
            ],
          )),
        ],
      ),
    );
  }
}

class _QuickNav extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final bool isLight;
  const _QuickNav({required this.icon, required this.label, required this.description, required this.color, required this.onTap, required this.isLight});

  @override
  State<_QuickNav> createState() => _QuickNavState();
}

class _QuickNavState extends State<_QuickNav> {
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
          width: 260, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.isLight ? Colors.white : const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovered ? widget.color.withOpacity(0.45) : (widget.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
            boxShadow: [BoxShadow(color: _hovered ? widget.color.withOpacity(0.12) : Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.icon, color: widget.color, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(widget.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.isLight ? const Color(0xFF0D1B2A) : Colors.white)),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, size: 14, color: _hovered ? widget.color : const Color(0xFF94A3B8)),
              ]),
              const SizedBox(height: 4),
              Text(widget.description, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)), maxLines: 2),
            ])),
          ]),
        ),
      ),
    );
  }
}