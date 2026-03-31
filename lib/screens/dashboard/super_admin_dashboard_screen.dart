import 'package:flutter/material.dart';
import '../../models/admin_dashboard_stats_model.dart';
import '../../models/admin_vaccines_screen.dart';
import '../../models/app_user.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../admin/admin_hospitals_screen.dart';
import '../admin/admin_schedules_screen.dart';
import '../admin/admin_users_screen.dart';
import '../login_screen.dart';
import 'base_dashboard_scaffold.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  final AppUser user;
  const SuperAdminDashboardScreen({super.key, required this.user});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  final AdminService _svc = AdminService();
  int _idx = 0;
  bool _loading = true;
  AdminDashboardStatsModel? _stats;

  static const _nav = [
    (Icons.grid_view_rounded, Icons.grid_view_rounded, 'Overview'),
    (Icons.local_hospital_outlined, Icons.local_hospital_rounded, 'Hospitals'),
    (Icons.people_outline_rounded, Icons.people_rounded, 'Users'),
    (Icons.vaccines_outlined, Icons.vaccines_rounded, 'Vaccines'),
    (Icons.event_note_outlined, Icons.event_note_rounded, 'Schedules'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _stats = await _svc.getDashboardStats(); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_overview(), const AdminHospitalsScreen(), const AdminUsersScreen(), const AdminVaccinesScreen(), const AdminSchedulesScreen()];
    return DashboardShell(
      role: 'Super Admin', accentColor: const Color(0xFF1565C0), user: widget.user,
      navItems: _nav, selectedIndex: _idx, onNavTap: (i) => setState(() => _idx = i),
      onRefresh: _load, onLogout: _logout, child: pages[_idx],
    );
  }

  Widget _overview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        WelcomeBanner(user: widget.user, accent: const Color(0xFF1565C0), subtitle: 'Manage hospitals, users, vaccines, and schedules from one control center.'),
        const SizedBox(height: 28),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_stats != null) ...[
          Wrap(spacing: 14, runSpacing: 14, children: [
            _KpiCard('Hospitals', _stats!.hospitalsCount, Icons.local_hospital_rounded, const Color(0xFF1565C0)),
            _KpiCard('Admins', _stats!.hospitalAdminsCount, Icons.admin_panel_settings_rounded, const Color(0xFF6A1B9A)),
            _KpiCard('Nurses', _stats!.nursesCount, Icons.medical_services_rounded, const Color(0xFF00695C)),
            _KpiCard('Parents', _stats!.parentsCount, Icons.family_restroom_rounded, const Color(0xFFF57C00)),
            _KpiCard('Children', _stats!.childrenCount, Icons.child_care_rounded, const Color(0xFFAD1457)),
            _KpiCard('Vaccines', _stats!.vaccinesCount, Icons.vaccines_rounded, const Color(0xFF283593)),
          ]),
          const SizedBox(height: 28),
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 700;
            final isLight = Theme.of(context).brightness == Brightness.light;
            final tables = [
              _RecentTable(title: 'Recent Hospitals', columns: const ['Name', 'City', 'Users'], rows: _stats!.recentHospitals.map((h) => [h.name, h.city ?? '—', '${h.usersCount}']).toList(), isLight: isLight),
              _RecentTable(title: 'Recent Users', columns: const ['Name', 'Email', 'Role'], rows: _stats!.recentUsers.map((u) => [u.fullName, u.email, u.role]).toList(), isLight: isLight),
            ];
            return wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: tables[0]), const SizedBox(width: 16), Expanded(child: tables[1])])
                : Column(children: [tables[0], const SizedBox(height: 16), tables[1]]);
          }),
        ],
      ]),
    );
  }
}

Widget _KpiCard(String label, int value, IconData icon, Color color) => _StatCard(label: label, value: value, icon: icon, color: color);

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: 168, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 14),
        Text('$value', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA), fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _RecentTable extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<List<String>> rows;
  final bool isLight;
  const _RecentTable({required this.title, required this.columns, required this.rows, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white))),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1)},
          children: [
            TableRow(
              decoration: BoxDecoration(color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824)),
              children: columns.map((c) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
              )).toList(),
            ),
            ...rows.map((r) => TableRow(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E2535)))),
              children: r.map((cell) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                child: Text(cell, style: TextStyle(fontSize: 13, color: isLight ? const Color(0xFF334155) : const Color(0xFFCBD5E1)), overflow: TextOverflow.ellipsis),
              )).toList(),
            )),
          ],
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}