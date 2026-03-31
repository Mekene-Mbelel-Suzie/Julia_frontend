import 'package:flutter/material.dart';
import '../../models/vaccination_record_model.dart';
import '../../services/nurse_service.dart';

class UpdateVaccinationRecordScreen extends StatefulWidget {
  final VaccinationRecordModel record;
  const UpdateVaccinationRecordScreen({super.key, required this.record});

  @override
  State<UpdateVaccinationRecordScreen> createState() => _UpdateVaccinationRecordScreenState();
}

class _UpdateVaccinationRecordScreenState extends State<UpdateVaccinationRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final NurseService nurseService = NurseService();

  late String selectedStatus;
  late final TextEditingController scheduledDateController;
  late final TextEditingController administeredDateController;
  late final TextEditingController batchNumberController;
  late final TextEditingController notesController;

  bool isLoading = false;

  static const _statuses = [
    (value: 'pending',   label: 'Pending',   icon: Icons.hourglass_top_rounded,  color: Color(0xFF1565C0)),
    (value: 'scheduled', label: 'Scheduled', icon: Icons.schedule_rounded,        color: Color(0xFFF59E0B)),
    (value: 'given',     label: 'Given',     icon: Icons.check_circle_rounded,    color: Color(0xFF00897B)),
    (value: 'missed',    label: 'Missed',    icon: Icons.cancel_rounded,          color: Color(0xFFE53935)),
    (value: 'cancelled', label: 'Cancelled', icon: Icons.block_rounded,           color: Color(0xFF94A3B8)),
  ];

  ({String value, String label, IconData icon, Color color}) get _activeStatus =>
      _statuses.firstWhere((s) => s.value == selectedStatus, orElse: () => _statuses.first);

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.record.status;
    scheduledDateController = TextEditingController(text: widget.record.scheduledDate ?? '');
    administeredDateController = TextEditingController(text: widget.record.administeredDate ?? '');
    batchNumberController = TextEditingController(text: widget.record.batchNumber ?? '');
    notesController = TextEditingController(text: widget.record.notes ?? '');
  }

  @override
  void dispose() {
    scheduledDateController.dispose();
    administeredDateController.dispose();
    batchNumberController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context, initialDate: now, firstDate: DateTime(2000), lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      ctrl.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await nurseService.updateVaccinationRecord(
        recordId: widget.record.id,
        status: selectedStatus,
        scheduledDate: scheduledDateController.text.trim().isEmpty ? null : scheduledDateController.text.trim(),
        administeredDate: administeredDateController.text.trim().isEmpty ? null : administeredDateController.text.trim(),
        batchNumber: batchNumberController.text.trim(),
        notes: notesController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text('Failed to update record: $e'))]),
        backgroundColor: const Color(0xFFE53935), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.all(16),
      ));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final r = widget.record;
    final status = _activeStatus;

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: isLight ? Colors.white : const Color(0xFF141824),
        elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: isLight ? const Color(0xFF0D1B2A) : Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('${r.vaccineName} – Dose ${r.doseNumber}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E2535))),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _heroBanner(status, r),
              const SizedBox(height: 24),
              _formCard(isLight, status),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _heroBanner(({String value, String label, IconData icon, Color color}) status, VaccinationRecordModel r) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [status.color, Color.lerp(status.color, Colors.black, 0.3)!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: status.color.withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)), child: Icon(status.icon, color: Colors.white, size: 26)),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${r.vaccineName} — Dose ${r.doseNumber}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: [_BannerChip(label: r.vaccineCode), _BannerChip(label: 'Due: ${r.dueDate}'), _BannerChip(label: status.label)]),
        ])),
      ]),
    );
  }

  Widget _formCard(bool isLight, ({String value, String label, IconData icon, Color color}) status) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader('Status', Icons.flag_outlined, isLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Wrap(spacing: 10, runSpacing: 10, children: _statuses.map((s) {
              final sel = selectedStatus == s.value;
              return GestureDetector(
                onTap: () => setState(() => selectedStatus = s.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? s.color.withOpacity(0.1) : (isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? s.color : (isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)), width: sel ? 1.5 : 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(s.icon, size: 15, color: sel ? s.color : (isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
                    const SizedBox(width: 7),
                    Text(s.label, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? s.color : (isLight ? const Color(0xFF475569) : const Color(0xFF8899AA)))),
                  ]),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Dates', Icons.date_range_outlined, isLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(children: [
              Expanded(child: _dateField(scheduledDateController, 'Scheduled Date', Icons.calendar_today_outlined, isLight, status.color, null)),
              const SizedBox(width: 16),
              Expanded(child: _dateField(administeredDateController, 'Administered Date', Icons.event_available_outlined, isLight, status.color,
                    (v) => selectedStatus == 'given' && (v == null || v.trim().isEmpty) ? 'Required when status is Given' : null,
              )),
            ]),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Additional Info', Icons.info_outline_rounded, isLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(children: [
              TextFormField(controller: batchNumberController, style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white), decoration: _dec('Batch Number', Icons.qr_code_2_outlined, isLight, status.color)),
              const SizedBox(height: 14),
              TextFormField(controller: notesController, maxLines: 4, style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white), decoration: _dec('Notes', Icons.note_alt_outlined, isLight, status.color).copyWith(alignLabelWithHint: true)),
            ]),
          ),
          const SizedBox(height: 24),
          _actionsBar(isLight, status),
        ]),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isLight) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: BoxDecoration(
      color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824),
      border: Border(top: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)), bottom: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
    ),
    child: Row(children: [Icon(icon, size: 16, color: const Color(0xFF00695C)), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white))]),
  );

  Widget _dateField(TextEditingController ctrl, String label, IconData icon, bool isLight, Color accent, String? Function(String?)? validator) => TextFormField(
    controller: ctrl, readOnly: true, onTap: () => _pickDate(ctrl), validator: validator,
    style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
    decoration: _dec(label, icon, isLight, accent).copyWith(suffixIcon: Icon(Icons.calendar_month_rounded, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
  );

  Widget _actionsBar(bool isLight, ({String value, String label, IconData icon, Color color}) status) => Container(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
    decoration: BoxDecoration(border: Border(top: BorderSide(color: isLight ? const Color(0xFFEEF2F7) : const Color(0xFF252B3B)))),
    child: Row(children: [
      Expanded(child: TextButton(
        onPressed: isLoading ? null : () => Navigator.pop(context),
        style: TextButton.styleFrom(foregroundColor: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)))),
        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      )),
      const SizedBox(width: 14),
      Expanded(flex: 2, child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(color: isLoading ? status.color.withOpacity(0.5) : status.color, borderRadius: BorderRadius.circular(12), boxShadow: isLoading ? [] : [BoxShadow(color: status.color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(12),
            child: InkWell(onTap: isLoading ? null : _submit, borderRadius: BorderRadius.circular(12),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : const Text('Save Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)))))),
      )),
    ]),
  );
}

class _BannerChip extends StatelessWidget {
  final String label;
  const _BannerChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(7)), child: Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w500)));
}

InputDecoration _dec(String label, IconData icon, bool isLight, Color accent) => InputDecoration(
  labelText: label,
  labelStyle: TextStyle(fontSize: 13.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF4A5568)),
  prefixIcon: Icon(icon, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
  filled: true, fillColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: accent, width: 1.5)),
  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFE53935))),
  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
);