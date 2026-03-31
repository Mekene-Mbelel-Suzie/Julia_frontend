import 'package:flutter/material.dart';
import '../../services/child_service.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChildService childService = ChildService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController birthWeightController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedGender = 'male';
  bool isActive = true;
  bool isLoading = false;

  static const Color _accent = Color(0xFFF57C00);

  @override
  void dispose() {
    firstNameController.dispose(); lastNameController.dispose();
    dateOfBirthController.dispose(); placeOfBirthController.dispose();
    bloodGroupController.dispose(); birthWeightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: DateTime(now.year - 1), firstDate: DateTime(2000), lastDate: now);
    if (picked != null) {
      dateOfBirthController.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final child = await childService.createChild(
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
      Navigator.pop(context, child);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text('Failed to add child: $e'))]),
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
      appBar: _buildAppBar(isLight),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _HeroBanner(),
              const SizedBox(height: 24),
              _FormCard(
                isLight: isLight,
                formKey: _formKey,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                dateOfBirthController: dateOfBirthController,
                placeOfBirthController: placeOfBirthController,
                bloodGroupController: bloodGroupController,
                birthWeightController: birthWeightController,
                notesController: notesController,
                selectedGender: selectedGender,
                isActive: isActive,
                isLoading: isLoading,
                onGenderChanged: (v) => setState(() => selectedGender = v ?? 'male'),
                onActiveChanged: (v) => setState(() => isActive = v),
                onPickDate: _pickDate,
                onCancel: () => Navigator.pop(context),
                onSubmit: submit,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isLight) {
    return AppBar(
      backgroundColor: isLight ? Colors.white : const Color(0xFF141824),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Add Child', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E2535))),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF57C00), Color(0xFFBF360C)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFFF57C00).withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add a Child', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
          const SizedBox(height: 8),
          Text('Register your child to generate a vaccine plan and track every upcoming dose.', style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 13.5, height: 1.45)),
        ])),
        const SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 36),
        ),
      ]),
    );
  }
}

class _FormCard extends StatelessWidget {
  final bool isLight;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController, lastNameController, dateOfBirthController, placeOfBirthController, bloodGroupController, birthWeightController, notesController;
  final String selectedGender;
  final bool isActive, isLoading;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onPickDate, onCancel, onSubmit;

  const _FormCard({
    required this.isLight, required this.formKey,
    required this.firstNameController, required this.lastNameController,
    required this.dateOfBirthController, required this.placeOfBirthController,
    required this.bloodGroupController, required this.birthWeightController,
    required this.notesController, required this.selectedGender,
    required this.isActive, required this.isLoading,
    required this.onGenderChanged, required this.onActiveChanged,
    required this.onPickDate, required this.onCancel, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Section(title: 'Basic Information', icon: Icons.person_outline_rounded, isLight: isLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(children: [
              Row(children: [
                Expanded(child: _Field(controller: firstNameController, label: 'First Name', icon: Icons.badge_outlined, isLight: isLight, validator: (v) => v == null || v.trim().isEmpty ? 'Enter first name' : null)),
                const SizedBox(width: 16),
                Expanded(child: _Field(controller: lastNameController, label: 'Last Name', icon: Icons.badge_outlined, isLight: isLight, validator: (v) => v == null || v.trim().isEmpty ? 'Enter last name' : null)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _GenderDropdown(value: selectedGender, onChanged: onGenderChanged, isLight: isLight)),
                const SizedBox(width: 16),
                Expanded(child: _DateField(controller: dateOfBirthController, onTap: onPickDate, isLight: isLight)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          _Section(title: 'Medical Details', icon: Icons.medical_information_outlined, isLight: isLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(children: [
              Row(children: [
                Expanded(child: _Field(controller: placeOfBirthController, label: 'Place of Birth', icon: Icons.location_on_outlined, isLight: isLight)),
                const SizedBox(width: 16),
                Expanded(child: _Field(controller: bloodGroupController, label: 'Blood Group', icon: Icons.bloodtype_outlined, isLight: isLight)),
              ]),
              const SizedBox(height: 14),
              _Field(controller: birthWeightController, label: 'Birth Weight (kg)', icon: Icons.monitor_weight_outlined, isLight: isLight, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 14),
              _NotesField(controller: notesController, isLight: isLight),
              const SizedBox(height: 14),
              _ActiveToggle(value: isActive, onChanged: onActiveChanged, isLight: isLight),
            ]),
          ),
          const SizedBox(height: 24),
          _FormActions(isLoading: isLoading, onCancel: onCancel, onSubmit: onSubmit, isLight: isLight),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isLight;
  const _Section({required this.title, required this.icon, required this.isLight});

  @override
  Widget build(BuildContext context) {
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
        Icon(icon, size: 16, color: const Color(0xFFF57C00)),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isLight;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _Field({required this.controller, required this.label, required this.icon, required this.isLight, this.validator, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, validator: validator, keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
      decoration: _dec(label, icon, isLight),
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  final bool isLight;
  const _DateField({required this.controller, required this.onTap, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, readOnly: true, onTap: onTap,
      style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
      validator: (v) => v == null || v.trim().isEmpty ? 'Select date of birth' : null,
      decoration: _dec('Date of Birth', Icons.calendar_today_outlined, isLight).copyWith(
        suffixIcon: Icon(Icons.calendar_month_rounded, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final bool isLight;
  const _GenderDropdown({required this.value, required this.onChanged, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value, onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
      dropdownColor: isLight ? Colors.white : const Color(0xFF1A1F2E),
      icon: Icon(Icons.unfold_more_rounded, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
      items: const [
        DropdownMenuItem(value: 'male', child: Row(children: [Text('♂  ', style: TextStyle(color: Color(0xFF1565C0))), Text('Male')])),
        DropdownMenuItem(value: 'female', child: Row(children: [Text('♀  ', style: TextStyle(color: Color(0xFFAD1457))), Text('Female')])),
      ],
      decoration: _dec('Gender', Icons.wc_outlined, isLight),
    );
  }
}

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLight;
  const _NotesField({required this.controller, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, maxLines: 4,
      style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
      decoration: _dec('Notes (optional)', Icons.note_alt_outlined, isLight).copyWith(alignLabelWithHint: true),
    );
  }
}

class _ActiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLight;
  const _ActiveToggle({required this.value, required this.onChanged, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
      ),
      child: SwitchListTile(
        value: value, onChanged: onChanged,
        title: Text('Active record', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
        subtitle: Text(value ? 'Child will appear in all workflows' : 'Child will be hidden from normal workflows',
            style: TextStyle(fontSize: 12, color: value ? const Color(0xFF00897B) : const Color(0xFF94A3B8))),
        activeColor: const Color(0xFFF57C00),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }
}

class _FormActions extends StatelessWidget {
  final bool isLoading, isLight;
  final VoidCallback onCancel, onSubmit;
  const _FormActions({required this.isLoading, required this.isLight, required this.onCancel, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: isLight ? const Color(0xFFEEF2F7) : const Color(0xFF252B3B)))),
      child: Row(children: [
        Expanded(child: TextButton(
          onPressed: isLoading ? null : onCancel,
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
            color: isLoading ? const Color(0xFFF57C00).withOpacity(0.5) : const Color(0xFFF57C00),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isLoading ? [] : [BoxShadow(color: const Color(0xFFF57C00).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(12),
              child: InkWell(onTap: isLoading ? null : onSubmit, borderRadius: BorderRadius.circular(12),
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : const Text('Save Child', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)))))),
        )),
      ]),
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