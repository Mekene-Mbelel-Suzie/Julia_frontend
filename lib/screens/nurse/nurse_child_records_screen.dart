import 'package:flutter/material.dart';
import '../../models/nurse_child_model.dart';
import '../../models/vaccination_record_model.dart';
import '../../services/nurse_service.dart';
import 'update_vaccination_record_screen.dart';

class NurseChildRecordsScreen extends StatefulWidget {
  final NurseChildModel child;
  const NurseChildRecordsScreen({super.key, required this.child});

  @override
  State<NurseChildRecordsScreen> createState() => _NurseChildRecordsScreenState();
}

class _NurseChildRecordsScreenState extends State<NurseChildRecordsScreen>
    with SingleTickerProviderStateMixin {
  final NurseService nurseService = NurseService();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool isLoading = true;
  List<VaccinationRecordModel> records = [];

  static const Color _accent = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    loadRecords();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> loadRecords() async {
    setState(() => isLoading = true);
    try {
      final data = await nurseService.getChildVaccinationRecords(widget.child.id);
      if (!mounted) return;
      setState(() { records = data; isLoading = false; });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text('Failed to load records: $e'))]),
        backgroundColor: const Color(0xFFE53935), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> openUpdate(VaccinationRecordModel record) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateVaccinationRecordScreen(record: record)));
    if (result != null) await loadRecords();
  }

  int get _given => records.where((r) => r.status == 'given').length;
  int get _pending => records.where((r) => r.status == 'pending' || r.status == 'scheduled').length;
  int get _missed => records.where((r) => r.status == 'missed' || r.status == 'cancelled').length;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final c = widget.child;
    final gc = c.gender == 'female' ? const Color(0xFFAD1457) : const Color(0xFF1565C0);
    final initials = '${c.firstName.isNotEmpty ? c.firstName[0] : ''}${c.lastName.isNotEmpty ? c.lastName[0] : ''}'.toUpperCase();

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: isLight ? Colors.white : const Color(0xFF141824),
        elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: isLight ? const Color(0xFF0D1B2A) : Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(c.fullName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
        actions: [Tooltip(message: 'Refresh', child: IconButton(icon: Icon(Icons.refresh_rounded, size: 20, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA)), onPressed: loadRecords)), const SizedBox(width: 8)],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E2535))),
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _hero(isLight, gc, initials, c),
            const SizedBox(height: 20),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _InfoChip(label: 'Parent', value: c.parentName ?? '—', icon: Icons.person_outline_rounded, isLight: isLight),
              _InfoChip(label: 'Gender', value: c.gender, icon: Icons.wc_outlined, isLight: isLight),
              _InfoChip(label: 'Date of Birth', value: c.dateOfBirth, icon: Icons.cake_outlined, isLight: isLight),
              _InfoChip(label: 'Status', value: c.isActive ? 'Active' : 'Inactive', icon: Icons.circle_outlined, isLight: isLight),
            ]),
            if (!isLoading) ...[const SizedBox(height: 20), Wrap(spacing: 12, runSpacing: 12, children: [
              _MiniKpi('Total', records.length, _accent, Icons.vaccines_rounded, isLight),
              _MiniKpi('Given', _given, const Color(0xFF00897B), Icons.check_circle_rounded, isLight),
              _MiniKpi('Pending', _pending, const Color(0xFFF59E0B), Icons.hourglass_top_rounded, isLight),
              _MiniKpi('Missed', _missed, const Color(0xFFE53935), Icons.warning_rounded, isLight),
            ])],
            const SizedBox(height: 24),
            Text('Vaccination Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
            const SizedBox(height: 14),
          ]),
        )),
        if (isLoading)
          SliverFillRemaining(child: Center(child: _PulseLoader(color: _accent)))
        else if (records.isEmpty)
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: _emptyState(isLight)))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => FadeTransition(opacity: _fadeAnim, child: Padding(padding: const EdgeInsets.only(bottom: 10), child: _RecordCard(record: records[i], isLight: isLight, onTap: () => openUpdate(records[i])))), childCount: records.length)),
          ),
      ]),
    );
  }

  Widget _hero(bool isLight, Color gc, String initials, NurseChildModel c) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(gradient: LinearGradient(colors: [_accent, Color.lerp(_accent, Colors.black, 0.28)!]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: _accent.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))]),
    child: Row(children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle), child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)))),
      const SizedBox(width: 18),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [_BannerChip(label: c.gender == 'female' ? '♀ Female' : '♂ Male'), _BannerChip(label: c.isActive ? 'Active' : 'Inactive'), _BannerChip(label: 'DOB: ${c.dateOfBirth}')]),
      ])),
    ]),
  );

  Widget _emptyState(bool isLight) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 48),
    decoration: BoxDecoration(color: isLight ? Colors.white : const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(16), border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.vaccines_outlined, size: 40, color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2A3040)),
      const SizedBox(height: 14),
      Text('No vaccination records found.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isLight ? const Color(0xFF475569) : const Color(0xFF64748B))),
    ]),
  );
}

class _RecordCard extends StatefulWidget {
  final VaccinationRecordModel record; final bool isLight; final VoidCallback onTap;
  const _RecordCard({required this.record, required this.isLight, required this.onTap});
  @override
  State<_RecordCard> createState() => _RecordCardState();
}
class _RecordCardState extends State<_RecordCard> {
  bool _hovered = false;
  Color get _sc => switch (widget.record.status) { 'given' => const Color(0xFF00897B), 'missed' || 'cancelled' => const Color(0xFFE53935), 'scheduled' => const Color(0xFFF59E0B), _ => const Color(0xFF1565C0) };
  IconData get _si => switch (widget.record.status) { 'given' => Icons.check_circle_rounded, 'missed' || 'cancelled' => Icons.cancel_rounded, 'scheduled' => Icons.schedule_rounded, _ => Icons.vaccines_rounded };
  String get _sl => switch (widget.record.status) { 'given' => 'Given', 'missed' => 'Missed', 'cancelled' => 'Cancelled', 'scheduled' => 'Scheduled', _ => widget.record.status };

  @override
  Widget build(BuildContext context) {
    final r = widget.record; final il = widget.isLight;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true), onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(color: il ? Colors.white : const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: _hovered ? _sc.withOpacity(0.4) : (il ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))), boxShadow: [BoxShadow(color: _hovered ? _sc.withOpacity(0.1) : Colors.black.withOpacity(0.03), blurRadius: _hovered ? 16 : 8, offset: const Offset(0, 4))]),
        child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: _sc.withOpacity(0.1), shape: BoxShape.circle), child: Icon(_si, color: _sc, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('${r.vaccineName} — Dose ${r.doseNumber}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: il ? const Color(0xFF0D1B2A) : Colors.white))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(7)), child: Text(_sl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _sc))),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 16, runSpacing: 6, children: [
              _Meta(icon: Icons.qr_code_outlined, label: r.vaccineCode, isLight: il),
              _Meta(icon: Icons.calendar_today_outlined, label: 'Due: ${r.dueDate}', isLight: il),
              if (r.administeredDate != null) _Meta(icon: Icons.check_outlined, label: 'Given: ${r.administeredDate}', isLight: il),
              if (r.batchNumber != null && r.batchNumber!.isNotEmpty) _Meta(icon: Icons.numbers_rounded, label: 'Batch: ${r.batchNumber}', isLight: il),
            ]),
            if (r.notes != null && r.notes!.trim().isNotEmpty) ...[const SizedBox(height: 8), Text(r.notes!, style: TextStyle(fontSize: 12, color: il ? const Color(0xFF64748B) : const Color(0xFF8899AA), fontStyle: FontStyle.italic))],
          ])),
          const SizedBox(width: 8),
          Icon(Icons.edit_rounded, size: 16, color: _hovered ? const Color(0xFF00695C) : (il ? const Color(0xFFCBD5E1) : const Color(0xFF2A3040))),
        ])),
      )),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon; final String label; final bool isLight;
  const _Meta({required this.icon, required this.label, required this.isLight});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 12, color: isLight ? const Color(0xFF64748B) : const Color(0xFF64748B)))]);
}

class _InfoChip extends StatelessWidget {
  final String label, value; final IconData icon; final bool isLight;
  const _InfoChip({required this.label, required this.value, required this.icon, required this.isLight});
  @override
  Widget build(BuildContext context) => Container(
    width: 200, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: isLight ? Colors.white : const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))]),
    child: Row(children: [Icon(icon, size: 15, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))), const SizedBox(height: 2), brevText(value, isLight)]))]),
  );

  Widget brevText(String v, bool il) => Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: il ? const Color(0xFF334155) : const Color(0xFFCBD5E1)), overflow: TextOverflow.ellipsis);
}

class _MiniKpi extends StatelessWidget {
  final String label; final int value; final Color color; final IconData icon; final bool isLight;
  const _MiniKpi(this.label, this.value, this.color, this.icon, this.isLight);
  @override
  Widget build(BuildContext context) => Container(
    width: 140, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: isLight ? Colors.white : const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.15)), boxShadow: [BoxShadow(color: color.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 15)), const SizedBox(height: 10), Text('$value', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1)), const SizedBox(height: 3), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA)))]),
  );
}

class _BannerChip extends StatelessWidget {
  final String label;
  const _BannerChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(7)), child: Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w500)));
}

class _PulseLoader extends StatefulWidget {
  final Color color;
  const _PulseLoader({required this.color});
  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}
class _PulseLoaderState extends State<_PulseLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c; late final Animation<double> _a;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true); _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _a, child: SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(widget.color))));
}