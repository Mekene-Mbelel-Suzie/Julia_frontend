import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../models/child_vaccination_summary_model.dart';
import '../../models/vaccination_record_model.dart';
import '../../services/child_service.dart';
import 'edit_child_screen.dart';

class ChildDetailScreen extends StatefulWidget {
  final ChildModel child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen>
    with SingleTickerProviderStateMixin {
  final ChildService childService = ChildService();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  late ChildModel child;
  ChildVaccinationSummaryModel? summary;
  List<VaccinationRecordModel> records = [];
  bool isLoading = true;
  bool generatingPlan = false;
  bool deleting = false;

  static const Color _accent = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();
    child = widget.child;
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final r = await childService.getVaccinationRecords(child.id);
      final s = await childService.getVaccinationSummary(child.id);
      if (!mounted) return;
      setState(() { records = r; summary = s; isLoading = false; });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() { records = []; summary = null; isLoading = false; });
      _snackError('Failed to load records: $e');
    }
  }

  void _snackError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text(msg))]),
    backgroundColor: const Color(0xFFE53935),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));

  void _snackSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [const Icon(Icons.check_circle_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Text(msg)]),
    backgroundColor: const Color(0xFF00897B),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));

  Future<void> generatePlan() async {
    setState(() => generatingPlan = true);
    try {
      await childService.generateVaccinationPlan(child.id);
      await _load();
      if (!mounted) return;
      _snackSuccess('Vaccination plan generated successfully');
    } catch (e) {
      if (!mounted) return;
      _snackError('Failed to generate plan: $e');
    } finally {
      if (mounted) setState(() => generatingPlan = false);
    }
  }

  Future<void> editChild() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditChildScreen(child: child)));
    if (result is ChildModel && mounted) {
      setState(() => child = result);
      await _load();
    }
  }

  Future<void> deleteChild() async {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 40, offset: const Offset(0, 16))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935), size: 22)),
            const SizedBox(height: 16),
            Text('Delete Child', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
            const SizedBox(height: 8),
            Text('Are you sure you want to delete ${child.fullName}? This action cannot be undone.', style: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8), height: 1.45)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)))),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
              )),
            ]),
          ]),
        ),
      ),
    );
    if (confirmed != true) return;
    setState(() => deleting = true);
    try {
      await childService.deleteChild(child.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => deleting = false);
      _snackError('Failed to delete child: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final genderColor = child.gender == 'female' ? const Color(0xFFAD1457) : const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: isLight ? Colors.white : const Color(0xFF141824),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: isLight ? const Color(0xFF0D1B2A) : Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(child.fullName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
        actions: [
          _AppBarAction(icon: Icons.edit_rounded, tooltip: 'Edit child', onTap: editChild, isLight: isLight),
          _AppBarAction(icon: Icons.delete_outline_rounded, tooltip: 'Delete child', onTap: deleting ? null : deleteChild, isLight: isLight, danger: true),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E2535))),
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _heroBanner(isLight, genderColor),
            const SizedBox(height: 20),
            _infoGrid(isLight),
            const SizedBox(height: 20),
            if (summary != null) ...[
              _summaryKpis(isLight),
              const SizedBox(height: 20),
            ],
            _generatePlanButton(isLight),
            const SizedBox(height: 28),
            Text('Vaccination Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
            const SizedBox(height: 14),
          ]),
        )),
        if (isLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_accent))))
        else if (records.isEmpty)
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: _emptyRecords(isLight)))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
              return FadeTransition(
                opacity: _fadeAnim,
                child: Padding(padding: const EdgeInsets.only(bottom: 10), child: _RecordCard(record: records[i], isLight: isLight)),
              );
            }, childCount: records.length)),
          ),
      ]),
    );
  }

  Widget _heroBanner(bool isLight, Color genderColor) {
    final initials = '${child.firstName.isNotEmpty ? child.firstName[0] : ''}${child.lastName.isNotEmpty ? child.lastName[0] : ''}'.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_accent, Color.lerp(_accent, Colors.black, 0.25)!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _accent.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
          child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20))),
        ),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(child.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
          const SizedBox(height: 6),
          Row(children: [
            _BannerChip(label: child.gender == 'female' ? '♀ Female' : '♂ Male'),
            const SizedBox(width: 8),
            _BannerChip(label: child.isActive ? 'Active' : 'Inactive'),
            const SizedBox(width: 8),
            _BannerChip(label: 'DOB: ${child.dateOfBirth}'),
          ]),
        ])),
      ]),
    );
  }

  Widget _infoGrid(bool isLight) {
    final items = [
      ('Place of Birth', child.placeOfBirth ?? '—', Icons.location_on_outlined),
      ('Blood Group', child.bloodGroup ?? '—', Icons.bloodtype_outlined),
      ('Birth Weight', child.birthWeightKg != null ? '${child.birthWeightKg} kg' : '—', Icons.monitor_weight_outlined),
      ('Notes', child.notes?.trim().isNotEmpty == true ? child.notes! : '—', Icons.note_alt_outlined),
    ];
    return Wrap(spacing: 12, runSpacing: 12, children: items.map((item) => _InfoChip(label: item.$1, value: item.$2, icon: item.$3, isLight: isLight)).toList());
  }

  Widget _summaryKpis(bool isLight) {
    return Wrap(spacing: 12, runSpacing: 12, children: [
      _MiniKpi('Total', summary!.total, const Color(0xFFF57C00), Icons.vaccines_rounded, isLight),
      _MiniKpi('Given', summary!.given, const Color(0xFF00897B), Icons.check_circle_rounded, isLight),
      _MiniKpi('Pending', summary!.pending, const Color(0xFFF59E0B), Icons.hourglass_top_rounded, isLight),
      _MiniKpi('Overdue', summary!.overdue, const Color(0xFFE53935), Icons.warning_rounded, isLight),
    ]);
  }

  Widget _generatePlanButton(bool isLight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: generatingPlan ? null : generatePlan,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: generatingPlan
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(_accent)))
                    : const Icon(Icons.auto_fix_high_rounded, color: _accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(generatingPlan ? 'Generating Plan...' : 'Generate Vaccination Plan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
                const SizedBox(height: 3),
                Text('Automatically create all required doses based on the child\'s date of birth.', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ])),
              Icon(Icons.chevron_right_rounded, color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2A3040)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _emptyRecords(bool isLight) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.vaccines_outlined, size: 40, color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2A3040)),
        const SizedBox(height: 14),
        Text('No vaccination records yet.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isLight ? const Color(0xFF475569) : const Color(0xFF64748B))),
        const SizedBox(height: 6),
        const Text('Generate a plan above to create vaccination records.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
      ]),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final VaccinationRecordModel record;
  final bool isLight;
  const _RecordCard({required this.record, required this.isLight});

  Color get _statusColor => switch (record.status) {
    'given' => const Color(0xFF00897B),
    'missed' || 'cancelled' => const Color(0xFFE53935),
    'scheduled' => const Color(0xFFF59E0B),
    _ => const Color(0xFF1565C0),
  };

  IconData get _statusIcon => switch (record.status) {
    'given' => Icons.check_circle_rounded,
    'missed' || 'cancelled' => Icons.cancel_rounded,
    'scheduled' => Icons.schedule_rounded,
    _ => Icons.vaccines_rounded,
  };

  String get _statusLabel => switch (record.status) {
    'given' => 'Given',
    'missed' => 'Missed',
    'cancelled' => 'Cancelled',
    'scheduled' => 'Scheduled',
    _ => record.status,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(_statusIcon, color: _statusColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('${record.vaccineName} — Dose ${record.doseNumber}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white))),
              _StatusBadge(label: _statusLabel, color: _statusColor),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 16, runSpacing: 6, children: [
              _MetaItem(icon: Icons.qr_code_outlined, label: record.vaccineCode, isLight: isLight),
              _MetaItem(icon: Icons.calendar_today_outlined, label: 'Due: ${record.dueDate}', isLight: isLight),
              if (record.administeredDate != null)
                _MetaItem(icon: Icons.check_outlined, label: 'Given: ${record.administeredDate}', isLight: isLight),
            ]),
            if (record.notes != null && record.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(record.notes!, style: TextStyle(fontSize: 12, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA), fontStyle: FontStyle.italic)),
            ],
          ])),
        ]),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.2)),
  );
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLight;
  const _MetaItem({required this.icon, required this.label, required this.isLight});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 12, color: isLight ? const Color(0xFF64748B) : const Color(0xFF64748B))),
  ]);
}

class _InfoChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool isLight;
  const _InfoChip({required this.label, required this.value, required this.icon, required this.isLight});

  @override
  Widget build(BuildContext context) => Container(
    width: 210,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isLight ? Colors.white : const Color(0xFF1A1F2E),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Row(children: [
      Icon(icon, size: 15, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isLight ? const Color(0xFF334155) : const Color(0xFFCBD5E1)), overflow: TextOverflow.ellipsis),
      ])),
    ]),
  );
}

class _MiniKpi extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool isLight;
  const _MiniKpi(this.label, this.value, this.color, this.icon, this.isLight);

  @override
  Widget build(BuildContext context) => Container(
    width: 148, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isLight ? Colors.white : const Color(0xFF1A1F2E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.15)),
      boxShadow: [BoxShadow(color: color.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 15)),
      const SizedBox(height: 10),
      Text('$value', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1)),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA))),
    ]),
  );
}

class _BannerChip extends StatelessWidget {
  final String label;
  const _BannerChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(7)),
    child: Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w500)),
  );
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isLight;
  final bool danger;
  const _AppBarAction({required this.icon, required this.tooltip, required this.onTap, required this.isLight, this.danger = false});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      color: danger ? const Color(0xFFE53935) : (isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA)),
    ),
  );
}