import 'package:flutter/material.dart';
import '../../models/admin_hospital_model.dart';
import '../../services/admin_service.dart';
import 'admin_shared.dart';

class AdminHospitalsScreen extends StatefulWidget {
  const AdminHospitalsScreen({super.key});

  @override
  State<AdminHospitalsScreen> createState() => _AdminHospitalsScreenState();
}

class _AdminHospitalsScreenState extends State<AdminHospitalsScreen>
    with SingleTickerProviderStateMixin {
  final AdminService adminService = AdminService();
  final TextEditingController searchController = TextEditingController();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool isLoading = true;
  List<AdminHospitalModel> hospitals = [];

  static const Color _accent = Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    loadHospitals();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); searchController.dispose(); super.dispose(); }

  Future<void> loadHospitals() async {
    setState(() => isLoading = true);
    try {
      final data = await adminService.getHospitals(search: searchController.text);
      if (!mounted) return;
      setState(() { hospitals = data; isLoading = false; });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text('Failed to load hospitals: $e'))]),
        backgroundColor: const Color(0xFFE53935), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> openForm({AdminHospitalModel? hospital}) async {
    final result = await showDialog<bool>(context: context, barrierColor: Colors.black54, builder: (_) => _HospitalFormDialog(hospital: hospital));
    if (result == true) await loadHospitals();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      color: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
          child: Column(children: [
            AdminPageHeader(
              title: 'Hospitals', subtitle: 'Create, edit and manage hospital records.',
              icon: Icons.local_hospital_rounded, accent: _accent,
              action: AdminPrimaryButton(label: 'Add Hospital', icon: Icons.add_rounded, color: _accent, onTap: () => openForm()),
            ),
            const SizedBox(height: 24),
            AdminSearchBar(controller: searchController, hint: 'Search hospitals by name or city…', onSearch: loadHospitals, accent: _accent),
            const SizedBox(height: 24),
          ]),
        )),
        if (isLoading)
          const SliverFillRemaining(child: Center(child: AdminLoader(color: _accent)))
        else if (hospitals.isEmpty)
          const SliverFillRemaining(child: AdminEmptyState(icon: Icons.local_hospital_outlined, title: 'No hospitals found', subtitle: 'Adjust your search or add a new hospital.', color: _accent))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 0.04 * (i + 1)), end: Offset.zero).animate(_fadeAnim),
                child: Padding(padding: const EdgeInsets.only(bottom: 10), child: _HospitalCard(hospital: hospitals[i], isLight: isLight, onEdit: () => openForm(hospital: hospitals[i]))),
              ),
            ), childCount: hospitals.length)),
          ),
      ]),
    );
  }
}

class _HospitalCard extends StatefulWidget {
  final AdminHospitalModel hospital;
  final bool isLight;
  final VoidCallback onEdit;
  const _HospitalCard({required this.hospital, required this.isLight, required this.onEdit});

  @override
  State<_HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<_HospitalCard> {
  bool _hov = false;
  static const Color _accent = Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    final h = widget.hospital;
    final isLight = widget.isLight;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hov ? _accent.withOpacity(0.4) : (isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
          boxShadow: [BoxShadow(color: _hov ? _accent.withOpacity(0.1) : Colors.black.withOpacity(0.04), blurRadius: _hov ? 24 : 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            Container(width: 44, height: 44,
                decoration: BoxDecoration(color: h.isActive ? _accent.withOpacity(0.1) : (isLight ? const Color(0xFFF1F5F9) : const Color(0xFF252B3B)), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.local_hospital_rounded, color: h.isActive ? _accent : const Color(0xFF94A3B8), size: 22)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(h.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
                const SizedBox(width: 10),
                AdminStatusChip(active: h.isActive),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                if (h.city != null) ...[Icon(Icons.location_on_outlined, size: 12, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), const SizedBox(width: 3), Text(h.city!, style: TextStyle(fontSize: 12.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF64748B))), const SizedBox(width: 12)],
                Icon(Icons.people_outline_rounded, size: 12, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
                const SizedBox(width: 3),
                Text('${h.usersCount} users', style: TextStyle(fontSize: 12.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF64748B))),
              ]),
            ])),
            Tooltip(message: 'Edit hospital', child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(color: _hov ? _accent.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
              child: IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: _hov ? _accent : (isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), onPressed: widget.onEdit),
            )),
          ]),
        ),
      ),
    );
  }
}

class _HospitalFormDialog extends StatefulWidget {
  final AdminHospitalModel? hospital;
  const _HospitalFormDialog({this.hospital});

  @override
  State<_HospitalFormDialog> createState() => _HospitalFormDialogState();
}

class _HospitalFormDialogState extends State<_HospitalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService adminService = AdminService();
  late final TextEditingController nameCtrl, addressCtrl, cityCtrl, phoneCtrl, emailCtrl;
  bool isActive = true, isLoading = false;
  static const Color _accent = Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.hospital?.name ?? '');
    addressCtrl = TextEditingController(text: widget.hospital?.address ?? '');
    cityCtrl = TextEditingController(text: widget.hospital?.city ?? '');
    phoneCtrl = TextEditingController(text: widget.hospital?.phone ?? '');
    emailCtrl = TextEditingController(text: widget.hospital?.email ?? '');
    isActive = widget.hospital?.isActive ?? true;
  }

  @override
  void dispose() { nameCtrl.dispose(); addressCtrl.dispose(); cityCtrl.dispose(); phoneCtrl.dispose(); emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      if (widget.hospital == null) {
        await adminService.createHospital(name: nameCtrl.text.trim(), address: addressCtrl.text.trim(), city: cityCtrl.text.trim(), phone: phoneCtrl.text.trim(), email: emailCtrl.text.trim(), isActive: isActive);
      } else {
        await adminService.updateHospital(hospitalId: widget.hospital!.id, name: nameCtrl.text.trim(), address: addressCtrl.text.trim(), city: cityCtrl.text.trim(), phone: phoneCtrl.text.trim(), email: emailCtrl.text.trim(), isActive: isActive);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: const Color(0xFFE53935), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.all(16)));
    } finally { if (mounted) setState(() => isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AdminDialog(
      title: widget.hospital == null ? 'Add Hospital' : 'Edit Hospital',
      icon: Icons.local_hospital_rounded, accent: _accent,
      isLoading: isLoading, onCancel: () => Navigator.pop(context), onSubmit: _submit,
      submitLabel: widget.hospital == null ? 'Create' : 'Update',
      content: Form(key: _formKey, child: Column(children: [
        AdminFormField(controller: nameCtrl, label: 'Hospital name', icon: Icons.business_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Enter hospital name' : null),
        const SizedBox(height: 14),
        AdminFormField(controller: addressCtrl, label: 'Address', icon: Icons.map_outlined),
        const SizedBox(height: 14),
        AdminFormField(controller: cityCtrl, label: 'City', icon: Icons.location_city_rounded),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AdminFormField(controller: phoneCtrl, label: 'Phone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone)),
          const SizedBox(width: 14),
          Expanded(child: AdminFormField(controller: emailCtrl, label: 'Email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress)),
        ]),
        const SizedBox(height: 14),
        AdminActiveToggle(value: isActive, onChanged: (v) => setState(() => isActive = v), accent: _accent, activeLabel: 'Hospital is currently active', inactiveLabel: 'Hospital is inactive'),
        const SizedBox(height: 4),
      ])),
    );
  }
}