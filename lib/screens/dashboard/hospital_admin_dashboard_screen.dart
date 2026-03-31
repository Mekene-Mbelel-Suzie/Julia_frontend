import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'base_dashboard_scaffold.dart';

class HospitalAdminDashboardScreen extends StatefulWidget {
  final AppUser user;
  const HospitalAdminDashboardScreen({super.key, required this.user});

  @override
  State<HospitalAdminDashboardScreen> createState() => _HospitalAdminDashboardScreenState();
}

class _HospitalAdminDashboardScreenState extends State<HospitalAdminDashboardScreen> {
  int _idx = 0;

  static const _nav = [
    (Icons.grid_view_rounded, Icons.grid_view_rounded, 'Overview'),
    (Icons.people_outline_rounded, Icons.people_rounded, 'Nurses'),
    (Icons.vaccines_outlined, Icons.vaccines_rounded, 'Vaccines'),
    (Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Reports'),
  ];

  static const Color _accent = Color(0xFF00838F);

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_overview(), _nurseTab(), _vaccineTab(), _reportsTab()];
    return DashboardShell(
      role: 'Hospital Admin', accentColor: _accent, user: widget.user,
      navItems: _nav, selectedIndex: _idx, onNavTap: (i) => setState(() => _idx = i),
      onRefresh: () => setState(() {}), onLogout: _logout, child: pages[_idx],
    );
  }

  Widget _overview() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final hospital = widget.user.hospital?['name'] ?? 'Your Hospital';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        WelcomeBanner(
          user: widget.user, accent: _accent,
          subtitle: 'Manage nurses, configure vaccines, and monitor hospital vaccination activity.',
        ),
        const SizedBox(height: 28),
        Wrap(spacing: 14, runSpacing: 14, children: [
          _KpiTile('Nurses', '—', Icons.medical_services_rounded, const Color(0xFF00838F), isLight),
          _KpiTile('Children', '—', Icons.child_care_rounded, const Color(0xFFF57C00), isLight),
          _KpiTile('Vaccines', '—', Icons.vaccines_rounded, const Color(0xFF1565C0), isLight),
          _KpiTile('Pending', '—', Icons.hourglass_top_rounded, const Color(0xFFAD1457), isLight),
        ]),
        const SizedBox(height: 28),
        _SectionLabel('Hospital at a Glance', isLight),
        const SizedBox(height: 12),
        _GlanceTable(hospitalName: hospital, isLight: isLight),
        const SizedBox(height: 28),
        _SectionLabel('Getting Started', isLight),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _StepCard(step: '1', title: 'Add Nurses', description: 'Create nurse accounts and assign them to this hospital.', icon: Icons.person_add_alt_1_rounded, color: _accent, onTap: () => setState(() => _idx = 1), isLight: isLight),
          _StepCard(step: '2', title: 'Configure Vaccines', description: 'Define available vaccines and dosage schedules.', icon: Icons.vaccines_rounded, color: const Color(0xFF1565C0), onTap: () => setState(() => _idx = 2), isLight: isLight),
          _StepCard(step: '3', title: 'View Reports', description: 'Monitor vaccination rates and coverage statistics.', icon: Icons.bar_chart_rounded, color: const Color(0xFFF57C00), onTap: () => setState(() => _idx = 3), isLight: isLight),
        ]),
      ]),
    );
  }

  Widget _nurseTab() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nurses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
            const SizedBox(height: 4),
            Text('Manage nurse accounts for ${widget.user.hospital?['name'] ?? 'your hospital'}.', style: TextStyle(fontSize: 13.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA))),
          ])),
          _PrimaryButton(label: 'Add Nurse', icon: Icons.person_add_alt_1_rounded, color: _accent, onTap: () {}),
        ]),
        const SizedBox(height: 24),
        _EmptyTablePlaceholder(icon: Icons.people_outline_rounded, message: 'No nurses added yet.\nClick "Add Nurse" to get started.', isLight: isLight),
      ]),
    );
  }

  Widget _vaccineTab() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Vaccines', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
            const SizedBox(height: 4),
            Text('Configure vaccines and dose schedules available at this hospital.', style: TextStyle(fontSize: 13.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA))),
          ])),
          _PrimaryButton(label: 'Add Vaccine', icon: Icons.add_rounded, color: const Color(0xFF1565C0), onTap: () {}),
        ]),
        const SizedBox(height: 24),
        _VaccineGuideTable(isLight: isLight),
      ]),
    );
  }

  Widget _reportsTab() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Reports', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
        const SizedBox(height: 4),
        Text('Monitor vaccination coverage and hospital statistics.', style: TextStyle(fontSize: 13.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA))),
        const SizedBox(height: 24),
        Wrap(spacing: 14, runSpacing: 14, children: [
          _ReportCard(title: 'Vaccination Rate', value: '—%', icon: Icons.trending_up_rounded, color: const Color(0xFF00838F), isLight: isLight),
          _ReportCard(title: 'Overdue Doses', value: '—', icon: Icons.warning_amber_rounded, color: const Color(0xFFAD1457), isLight: isLight),
          _ReportCard(title: 'Completed This Month', value: '—', icon: Icons.check_circle_outline_rounded, color: const Color(0xFF1565C0), isLight: isLight),
        ]),
        const SizedBox(height: 24),
        _EmptyTablePlaceholder(icon: Icons.bar_chart_rounded, message: 'Report data will appear here once\nchildren are added and vaccinations are recorded.', isLight: isLight),
      ]),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLight;
  const _KpiTile(this.label, this.value, this.icon, this.color, this.isLight);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 14),
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA))),
      ]),
    );
  }
}

class _GlanceTable extends StatelessWidget {
  final String hospitalName;
  final bool isLight;
  const _GlanceTable({required this.hospitalName, required this.isLight});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Hospital', hospitalName),
      ('Status', 'Active'),
      ('Vaccination Module', 'Enabled'),
      ('Data Access', 'Hospital-scoped'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Table(
        columnWidths: const {0: FixedColumnWidth(200), 1: FlexColumnWidth()},
        children: rows.asMap().entries.map((e) => TableRow(
          decoration: BoxDecoration(border: e.key == 0 ? null : Border(top: BorderSide(color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E2535)))),
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                child: Text(e.value.$1, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                child: e.value.$1 == 'Status'
                    ? Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00897B), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  const Text('Active', style: TextStyle(fontSize: 13.5, color: Color(0xFF00897B), fontWeight: FontWeight.w600)),
                ])
                    : Text(e.value.$2, style: TextStyle(fontSize: 13.5, color: isLight ? const Color(0xFF334155) : const Color(0xFFCBD5E1)))),
          ],
        )).toList(),
      ),
    );
  }
}

class _VaccineGuideTable extends StatelessWidget {
  final bool isLight;
  const _VaccineGuideTable({required this.isLight});

  static const _items = [
    ('BCG', 'Birth', '1', 'Tuberculosis prevention'),
    ('Hepatitis B', 'Birth, 6w, 10w, 14w', '4', 'Hepatitis B prevention'),
    ('OPV', '6w, 10w, 14w', '3', 'Polio prevention'),
    ('Measles', '9 months, 15-18 months', '2', 'Measles prevention'),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Text('Vaccine Reference', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white))),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(2), 2: FixedColumnWidth(60), 3: FlexColumnWidth(2)},
          children: [
            TableRow(
              decoration: BoxDecoration(color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824)),
              children: ['Vaccine', 'Schedule', 'Doses', 'Purpose'].map((h) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(h, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
              )).toList(),
            ),
            ..._items.map((r) => TableRow(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E2535)))),
              children: [r.$1, r.$2, r.$3, r.$4].map((cell) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Text(cell, style: TextStyle(fontSize: 13, color: isLight ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
              )).toList(),
            )),
          ],
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}

class _StepCard extends StatefulWidget {
  final String step;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLight;
  const _StepCard({required this.step, required this.title, required this.description, required this.icon, required this.color, required this.onTap, required this.isLight});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
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
          width: 228, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.isLight ? Colors.white : const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovered ? widget.color.withOpacity(0.4) : (widget.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
            boxShadow: [BoxShadow(color: _hovered ? widget.color.withOpacity(0.1) : Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 26, height: 26, decoration: BoxDecoration(color: widget.color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Text(widget.step, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: widget.color)))),
              const Spacer(),
              Icon(widget.icon, color: widget.color.withOpacity(0.5), size: 18),
            ]),
            const SizedBox(height: 12),
            Text(widget.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.isLight ? const Color(0xFF0D1B2A) : Colors.white)),
            const SizedBox(height: 4),
            Text(widget.description, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4)),
            const SizedBox(height: 10),
            Row(children: [
              Text('Open', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.color)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 12, color: widget.color),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLight;
  const _ReportCard({required this.title, required this.value, required this.icon, required this.color, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 14),
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA))),
      ]),
    );
  }
}

class _EmptyTablePlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isLight;
  const _EmptyTablePlaceholder({required this.icon, required this.message, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 52),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 40, color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2A3040)),
        const SizedBox(height: 14),
        Text(message, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.6, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
      ]),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: widget.color.withOpacity(_hovered ? 0.35 : 0.2), blurRadius: _hovered ? 16 : 8, offset: const Offset(0, 4))],
        ),
        child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(12),
            child: InkWell(onTap: widget.onTap, borderRadius: BorderRadius.circular(12),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(widget.icon, color: Colors.white, size: 17),
                      const SizedBox(width: 8),
                      Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    ])))),
      ),
    );
  }
}

Widget _SectionLabel(String text, bool isLight) => Text(text,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.6,
        color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)));