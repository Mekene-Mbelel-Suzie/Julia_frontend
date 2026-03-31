import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../services/child_service.dart';

class EditChildScreen extends StatefulWidget {
  final ChildModel child;
  const EditChildScreen({super.key, required this.child});

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChildService childService = ChildService();

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController dateOfBirthController;
  late final TextEditingController placeOfBirthController;
  late final TextEditingController bloodGroupController;
  late final TextEditingController birthWeightController;
  late final TextEditingController notesController;

  late String selectedGender;
  bool isActive = true;
  bool isLoading = false;

  static const Color _accent = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();
    final c = widget.child;
    firstNameController = TextEditingController(text: c.firstName);
    lastNameController = TextEditingController(text: c.lastName);
    dateOfBirthController = TextEditingController(text: c.dateOfBirth);
    placeOfBirthController = TextEditingController(text: c.placeOfBirth ?? '');
    bloodGroupController = TextEditingController(text: c.bloodGroup ?? '');
    birthWeightController = TextEditingController(text: c.birthWeightKg ?? '');
    notesController = TextEditingController(text: c.notes ?? '');
    selectedGender = c.gender;
    isActive = c.isActive;
  }

  @override
  void dispose() {
    firstNameController.dispose(); lastNameController.dispose();
    dateOfBirthController.dispose(); placeOfBirthController.dispose();
    bloodGroupController.dispose(); birthWeightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final parts = dateOfBirthController.text.split('-');
    DateTime initial;
    try { initial = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])); }
    catch (_) { initial = DateTime.now(); }
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) {
      dateOfBirthController.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final updated = await childService.updateChild(
        childId: widget.child.id,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: selectedGender,
        dateOfBirth: dateOfBirthController.text.trim(),
        placeOfBirth: placeOfBirthController.text.trim(),
        bloodGroup: bloodGroupController.text.trim(),
        birthWeightKg: birthWeightController.text.trim(),
        notes: notesController.text.trim(),
        isActive: isActive,
      );
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text('Failed to update child: $e'))]),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: isLight ? Colors.white : const Color(0xFF141824),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: isLight ? const Color(0xFF0D1B2A) : Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Edit Child', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E2535))),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _editBanner(isLight),
              const SizedBox(height: 24),
              _formCard(isLight),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _editBanner(bool isLight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: _accent.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.edit_rounded, color: _accent, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Editing: ${widget.child.fullName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white, letterSpacing: -0.2)),
          const SizedBox(height: 4),
          Text('Update the child information below. Required fields are marked.', style: TextStyle(fontSize: 13, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA))),
        ])),
      ]),
    );
  }

  Widget _formCard(bool isLight) {
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
          _sectionHeader('Basic Information', Icons.person_outline_rounded, isLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(children: [
              Row(children: [
                Expanded(child: _field(firstNameController, 'First Name', Icons.badge_outlined, isLight, validator: (v) => v == null || v.trim().isEmpty ? 'Enter first name' : null)),
                const SizedBox(width: 16),
                Expanded(child: _field(lastNameController, 'Last Name', Icons.badge_outlined, isLight, validator: (v) => v == null || v.trim().isEmpty ? 'Enter last name' : null)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  onChanged: (v) => setState(() => selectedGender = v ?? 'male'),
                  style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
                  dropdownColor: isLight ? Colors.white : const Color(0xFF1A1F2E),
                  icon: Icon(Icons.unfold_more_rounded, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Row(children: [Text('♂  ', style: TextStyle(color: Color(0xFF1565C0))), Text('Male')])),
                    DropdownMenuItem(value: 'female', child: Row(children: [Text('♀  ', style: TextStyle(color: Color(0xFFAD1457))), Text('Female')])),
                  ],
                  decoration: _dec('Gender', Icons.wc_outlined, isLight),
                )),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(
                  controller: dateOfBirthController, readOnly: true, onTap: _pickDate,
                  style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Select date of birth' : null,
                  decoration: _dec('Date of Birth', Icons.calendar_today_outlined, isLight).copyWith(
                      suffixIcon: Icon(Icons.calendar_month_rounded, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
                )),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Medical Details', Icons.medical_information_outlined, isLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(children: [
              Row(children: [
                Expanded(child: _field(placeOfBirthController, 'Place of Birth', Icons.location_on_outlined, isLight)),
                const SizedBox(width: 16),
                Expanded(child: _field(bloodGroupController, 'Blood Group', Icons.bloodtype_outlined, isLight)),
              ]),
              const SizedBox(height: 14),
              _field(birthWeightController, 'Birth Weight (kg)', Icons.monitor_weight_outlined, isLight, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 14),
              TextFormField(
                controller: notesController, maxLines: 4,
                style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
                decoration: _dec('Notes', Icons.note_alt_outlined, isLight).copyWith(alignLabelWithHint: true),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824), borderRadius: BorderRadius.circular(11), border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
                child: SwitchListTile(
                  value: isActive, onChanged: (v) => setState(() => isActive = v),
                  title: Text('Active record', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
                  subtitle: Text(isActive ? 'Child will appear in all workflows' : 'Child will be hidden from normal workflows',
                      style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFF00897B) : const Color(0xFF94A3B8))),
                  activeColor: _accent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: isLight ? const Color(0xFFEEF2F7) : const Color(0xFF252B3B)))),
            child: Row(children: [
              Expanded(child: TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              )),
              const SizedBox(width: 14),
              Expanded(flex: 2, child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  color: isLoading ? _accent.withOpacity(0.5) : _accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isLoading ? [] : [BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(12),
                    child: InkWell(onTap: isLoading ? null : _submit, borderRadius: BorderRadius.circular(12),
                        child: Padding(padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)))))),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824),
        border: Border(
          top: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
          bottom: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
        ),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: _accent),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, bool isLight, {String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl, validator: validator, keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
      decoration: _dec(label, icon, isLight),
    );
  }
}

InputDecoration _dec(String label, IconData icon, bool isLight) => InputDecoration(
  labelText: label,
  labelStyle: TextStyle(fontSize: 13.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF4A5568)),
  prefixIcon: Icon(icon, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
  filled: true,
  fillColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFF57C00), width: 1.5)),
  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFE53935))),
  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
);