import 'package:flutter/material.dart';
import '../../models/vaccine_model.dart';
import '../../services/admin_service.dart';
import 'admin_shared.dart';

class AdminVaccinesScreen extends StatefulWidget {
  const AdminVaccinesScreen({super.key});

  @override
  State<AdminVaccinesScreen> createState() => _AdminVaccinesScreenState();
}

class _AdminVaccinesScreenState extends State<AdminVaccinesScreen>
    with SingleTickerProviderStateMixin {
  final AdminService adminService = AdminService();
  final TextEditingController searchController = TextEditingController();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool isLoading = true;
  List<VaccineModel> vaccines = [];
  static const Color _accent = Color(0xFF283593);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); searchController.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final data = await adminService.getVaccines();
      if (!mounted) return;
      setState(() { vaccines = data; isLoading = false; });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text('Failed to load vaccines: $e'))]),
        backgroundColor: const Color(0xFFE53935), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> openForm({VaccineModel? vaccine}) async {
    final result = await showDialog<bool>(context: context, barrierColor: Colors.black54, builder: (_) => _VaccineFormDialog(vaccine: vaccine));
    if (result == true) await _load();
  }

  List<VaccineModel> get _filtered {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return vaccines;
    return vaccines.where((v) => v.name.toLowerCase().contains(q) || v.code.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final filtered = _filtered;
    return Container(
      color: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
          child: Column(children: [
            AdminPageHeader(
              title: 'Vaccines', subtitle: 'Define vaccines used in the vaccination program.',
              icon: Icons.vaccines_rounded, accent: _accent,
              action: AdminPrimaryButton(label: 'Add Vaccine', icon: Icons.add_rounded, color: _accent, onTap: () => openForm()),
            ),
            const SizedBox(height: 24),
            AdminSearchBar(controller: searchController, hint: 'Search by name or code…', onSearch: () => setState(() {}), accent: _accent),
            const SizedBox(height: 24),
          ]),
        )),
        if (isLoading)
          const SliverFillRemaining(child: Center(child: AdminLoader(color: _accent)))
        else if (filtered.isEmpty)
          const SliverFillRemaining(child: AdminEmptyState(icon: Icons.vaccines_outlined, title: 'No vaccines found', subtitle: 'Add a vaccine to start building schedules.', color: _accent))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 0.04 * (i + 1)), end: Offset.zero).animate(_fadeAnim),
                child: Padding(padding: const EdgeInsets.only(bottom: 10), child: _VaccineCard(vaccine: filtered[i], isLight: isLight, onEdit: () => openForm(vaccine: filtered[i]))),
              ),
            ), childCount: filtered.length)),
          ),
      ]),
    );
  }
}

class _VaccineCard extends StatefulWidget {
  final VaccineModel vaccine; final bool isLight; final VoidCallback onEdit;
  const _VaccineCard({required this.vaccine, required this.isLight, required this.onEdit});
  @override
  State<_VaccineCard> createState() => _VaccineCardState();
}

class _VaccineCardState extends State<_VaccineCard> {
  bool _hov = false;
  static const Color _accent = Color(0xFF283593);

  @override
  Widget build(BuildContext context) {
    final v = widget.vaccine; final isLight = widget.isLight;
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
                decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.vaccines_rounded, color: _accent, size: 22)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(v.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
                const SizedBox(width: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _accent.withOpacity(0.08), borderRadius: BorderRadius.circular(6)), child: Text(v.code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _accent, letterSpacing: 0.3))),
                const SizedBox(width: 8),
                AdminStatusChip(active: v.isActive),
                if (v.numberOfDoses != null) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF64748B).withOpacity(0.08), borderRadius: BorderRadius.circular(6)), child: Text('${v.numberOfDoses} doses', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))))],
              ]),
              if (v.description != null && v.description!.trim().isNotEmpty) ...[const SizedBox(height: 5), Text(v.description!, style: TextStyle(fontSize: 12.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis)],
            ])),
            Tooltip(message: 'Edit vaccine', child: AnimatedContainer(duration: const Duration(milliseconds: 160), decoration: BoxDecoration(color: _hov ? _accent.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: _hov ? _accent : (isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), onPressed: widget.onEdit))),
          ]),
        ),
      ),
    );
  }
}

class _VaccineFormDialog extends StatefulWidget {
  final VaccineModel? vaccine;
  const _VaccineFormDialog({this.vaccine});
  @override
  State<_VaccineFormDialog> createState() => _VaccineFormDialogState();
}

class _VaccineFormDialogState extends State<_VaccineFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService adminService = AdminService();
  late final TextEditingController nameCtrl, codeCtrl, descCtrl, dosesCtrl;
  bool isActive = true, isLoading = false;
  static const Color _accent = Color(0xFF283593);

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.vaccine?.name ?? '');
    codeCtrl = TextEditingController(text: widget.vaccine?.code ?? '');
    descCtrl = TextEditingController(text: widget.vaccine?.description ?? '');
    dosesCtrl = TextEditingController(text: widget.vaccine?.numberOfDoses?.toString() ?? '');
    isActive = widget.vaccine?.isActive ?? true;
  }

  @override
  void dispose() { nameCtrl.dispose(); codeCtrl.dispose(); descCtrl.dispose(); dosesCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      if (widget.vaccine == null) {
        await adminService.createVaccine(name: nameCtrl.text.trim(), code: codeCtrl.text.trim(), description: descCtrl.text.trim(), numberOfDoses: int.tryParse(dosesCtrl.text.trim()) ?? 0, isActive: isActive, category: '');
      } else {
        await adminService.updateVaccine(vaccineId: widget.vaccine!.id, name: nameCtrl.text.trim(), code: codeCtrl.text.trim(), description: descCtrl.text.trim(),
            isActive: isActive, category: '',numberOfDoses: int.tryParse(dosesCtrl.text.trim()) ?? 0, );
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
      title: widget.vaccine == null ? 'Add Vaccine' : 'Edit Vaccine',
      icon: Icons.vaccines_rounded, accent: _accent,
      isLoading: isLoading, onCancel: () => Navigator.pop(context), onSubmit: _submit,
      submitLabel: widget.vaccine == null ? 'Create' : 'Update',
      content: Form(key: _formKey, child: Column(children: [
        Row(children: [
          Expanded(flex: 2, child: AdminFormField(controller: nameCtrl, label: 'Vaccine name', icon: Icons.vaccines_outlined, validator: (v) => v == null || v.trim().isEmpty ? 'Enter vaccine name' : null)),
          const SizedBox(width: 14),
          Expanded(child: AdminFormField(controller: codeCtrl, label: 'Code', icon: Icons.tag_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Enter code' : null)),
        ]),
        const SizedBox(height: 14),
        AdminFormField(controller: dosesCtrl, label: 'Number of doses', icon: Icons.format_list_numbered_rounded, keyboardType: TextInputType.number),
        const SizedBox(height: 14),
        AdminFormField(controller: descCtrl, label: 'Description (optional)', icon: Icons.description_outlined, maxLines: 3),
        const SizedBox(height: 14),
        AdminActiveToggle(value: isActive, onChanged: (v) => setState(() => isActive = v), accent: _accent, activeLabel: 'Vaccine is available for scheduling', inactiveLabel: 'Vaccine is not available'),
        const SizedBox(height: 4),
      ])),
    );
  }
}