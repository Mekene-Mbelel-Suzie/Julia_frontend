import 'package:flutter/material.dart';
import '../../models/admin_hospital_model.dart';
import '../../models/admin_user_model.dart';
import '../../services/admin_service.dart';
import 'admin_shared.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  final AdminService adminService = AdminService();
  final TextEditingController searchController = TextEditingController();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool isLoading = true;
  List<AdminUserModel> users = [];
  List<AdminHospitalModel> hospitals = [];
  String selectedRole = '';

  static const Color _accent = Color(0xFF9C27B0);

  static const _roleFilters = [
    _RoleMeta('', 'All Roles', Icons.people_outline_rounded, Color(0xFF64748B)),
    _RoleMeta('hospital_admin', 'Hospital Admin', Icons.admin_panel_settings_outlined, Color(0xFF1976D2)),
    _RoleMeta('nurse', 'Nurse', Icons.medical_services_outlined, Color(0xFF00695C)),
    _RoleMeta('parent', 'Parent', Icons.family_restroom_outlined, Color(0xFFF57C00)),
    _RoleMeta('super_admin', 'Super Admin', Icons.verified_user_outlined, Color(0xFFE53935)),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _bootstrap();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); searchController.dispose(); super.dispose(); }

  Future<void> _bootstrap() async { await _loadHospitals(); await _loadUsers(); }

  Future<void> _loadHospitals() async {
    try { hospitals = await adminService.getHospitals(); if (mounted) setState(() {}); } catch (_) {}
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await adminService.getUsers(search: searchController.text, role: selectedRole.isEmpty ? null : selectedRole);
      if (!mounted) return;
      setState(() { users = data; isLoading = false; });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text('Failed to load users: $e'))]),
        backgroundColor: const Color(0xFFE53935), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> openForm({AdminUserModel? user}) async {
    final result = await showDialog<bool>(context: context, barrierColor: Colors.black54, builder: (_) => _UserFormDialog(user: user, hospitals: hospitals));
    if (result == true) await _loadUsers();
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
              title: 'Users', subtitle: 'Create and manage platform users.',
              icon: Icons.manage_accounts_rounded, accent: _accent,
              action: AdminPrimaryButton(label: 'Add User', icon: Icons.person_add_alt_1_rounded, color: _accent, onTap: () => openForm()),
            ),
            const SizedBox(height: 24),
            _filterBar(isLight),
            const SizedBox(height: 24),
          ]),
        )),
        if (isLoading)
          const SliverFillRemaining(child: Center(child: AdminLoader(color: _accent)))
        else if (users.isEmpty)
          const SliverFillRemaining(child: AdminEmptyState(icon: Icons.people_outline_rounded, title: 'No users found', subtitle: 'Adjust your filters or add a new user.', color: _accent))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 0.04 * (i + 1)), end: Offset.zero).animate(_fadeAnim),
                child: Padding(padding: const EdgeInsets.only(bottom: 10), child: _UserCard(user: users[i], isLight: isLight, onEdit: () => openForm(user: users[i]))),
              ),
            ), childCount: users.length)),
          ),
      ]),
    );
  }

  Widget _filterBar(bool isLight) => Container(
    decoration: BoxDecoration(
      color: isLight ? Colors.white : const Color(0xFF1A1F2E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      const SizedBox(width: 16),
      Icon(Icons.search_rounded, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568), size: 20),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        controller: searchController, onSubmitted: (_) => _loadUsers(),
        style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by name or email…',
          hintStyle: TextStyle(color: isLight ? const Color(0xFFB0BEC5) : const Color(0xFF4A5568), fontSize: 14),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      )),
      Container(height: 32, width: 1, color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B), margin: const EdgeInsets.symmetric(vertical: 10)),
      const SizedBox(width: 12),
      DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: selectedRole,
        icon: Icon(Icons.unfold_more_rounded, size: 16, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
        style: TextStyle(fontSize: 13, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
        dropdownColor: isLight ? Colors.white : const Color(0xFF1A1F2E),
        items: _roleFilters.map((r) => DropdownMenuItem<String>(value: r.value, child: Row(children: [Icon(r.icon, size: 14, color: r.color), const SizedBox(width: 8), Text(r.label)]))).toList(),
        onChanged: (v) => setState(() => selectedRole = v ?? ''),
      )),
      const SizedBox(width: 4),
      Container(margin: const EdgeInsets.all(6), child: TextButton(
        onPressed: _loadUsers,
        style: TextButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        child: const Text('Filter'),
      )),
    ]),
  );
}

class _RoleMeta { final String value, label; final IconData icon; final Color color; const _RoleMeta(this.value, this.label, this.icon, this.color); }

class _UserCard extends StatefulWidget {
  final AdminUserModel user; final bool isLight; final VoidCallback onEdit;
  const _UserCard({required this.user, required this.isLight, required this.onEdit});
  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _hov = false;

  static Color _rc(String r) => switch (r) { 'super_admin' => const Color(0xFFE53935), 'hospital_admin' => const Color(0xFF1976D2), 'nurse' => const Color(0xFF00695C), 'parent' => const Color(0xFFF57C00), _ => const Color(0xFF9C27B0) };
  static IconData _ri(String r) => switch (r) { 'super_admin' => Icons.verified_user_rounded, 'hospital_admin' => Icons.admin_panel_settings_rounded, 'nurse' => Icons.medical_services_rounded, 'parent' => Icons.family_restroom_rounded, _ => Icons.person_rounded };
  static String _rl(String r) => switch (r) { 'super_admin' => 'Super Admin', 'hospital_admin' => 'Hospital Admin', 'nurse' => 'Nurse', 'parent' => 'Parent', _ => r };

  String get _initials { final p = widget.user.fullName.trim().split(' '); return p.length >= 2 ? '${p.first[0]}${p.last[0]}'.toUpperCase() : widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : '?'; }

  @override
  Widget build(BuildContext context) {
    final u = widget.user; final isLight = widget.isLight; final color = _rc(u.role);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hov ? color.withOpacity(0.35) : (isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
          boxShadow: [BoxShadow(color: _hov ? color.withOpacity(0.1) : Colors.black.withOpacity(0.04), blurRadius: _hov ? 24 : 10, offset: const Offset(0, 4))],
        ),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle), child: Center(child: Text(_initials, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(u.fullName, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_ri(u.role), size: 11, color: color), const SizedBox(width: 4), Text(_rl(u.role), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))])),
              if (!u.isActive) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF252B3B), borderRadius: BorderRadius.circular(6)), child: const Text('Inactive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))))],
            ]),
            const SizedBox(height: 5),
            Row(children: [
              Icon(Icons.mail_outline_rounded, size: 12, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), const SizedBox(width: 4),
              Text(u.email, style: TextStyle(fontSize: 12.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF64748B))),
              if (u.hospital?['name'] != null) ...[const SizedBox(width: 12), Icon(Icons.local_hospital_outlined, size: 12, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), const SizedBox(width: 4), Text(u.hospital!['name'], style: TextStyle(fontSize: 12.5, color: isLight ? const Color(0xFF64748B) : const Color(0xFF64748B)))],
            ]),
          ])),
          Tooltip(message: 'Edit user', child: AnimatedContainer(duration: const Duration(milliseconds: 160), decoration: BoxDecoration(color: _hov ? color.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: _hov ? color : (isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), onPressed: widget.onEdit))),
        ])),
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final AdminUserModel? user; final List<AdminHospitalModel> hospitals;
  const _UserFormDialog({this.user, required this.hospitals});
  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService adminService = AdminService();
  late final TextEditingController firstCtrl, lastCtrl, emailCtrl, phoneCtrl, pwCtrl;
  String selectedRole = 'nurse';
  int? selectedHospitalId;
  bool isActive = true, isLoading = false, _pwVisible = false;
  static const Color _accent = Color(0xFF9C27B0);

  static const _roleOpts = [
    _RoleMeta('hospital_admin', 'Hospital Admin', Icons.admin_panel_settings_outlined, Color(0xFF1976D2)),
    _RoleMeta('nurse', 'Nurse', Icons.medical_services_outlined, Color(0xFF00695C)),
    _RoleMeta('parent', 'Parent', Icons.family_restroom_outlined, Color(0xFFF57C00)),
    _RoleMeta('super_admin', 'Super Admin', Icons.verified_user_outlined, Color(0xFFE53935)),
  ];

  @override
  void initState() {
    super.initState();
    firstCtrl = TextEditingController(text: widget.user?.firstName ?? '');
    lastCtrl = TextEditingController(text: widget.user?.lastName ?? '');
    emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    phoneCtrl = TextEditingController(text: widget.user?.phone ?? '');
    pwCtrl = TextEditingController();
    selectedRole = widget.user?.role ?? 'nurse';
    selectedHospitalId = widget.user?.hospital?['id'];
    isActive = widget.user?.isActive ?? true;
  }

  @override
  void dispose() { firstCtrl.dispose(); lastCtrl.dispose(); emailCtrl.dispose(); phoneCtrl.dispose(); pwCtrl.dispose(); super.dispose(); }

  bool get _needsHospital => selectedRole == 'nurse' || selectedRole == 'hospital_admin';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      if (widget.user == null) {
        await adminService.createUser(firstName: firstCtrl.text.trim(), lastName: lastCtrl.text.trim(), email: emailCtrl.text.trim(), phone: phoneCtrl.text.trim(), role: selectedRole, hospitalId: _needsHospital ? selectedHospitalId : null, password: pwCtrl.text.trim(), isActive: isActive);
      } else {
        await adminService.updateUser(userId: widget.user!.id, firstName: firstCtrl.text.trim(), lastName: lastCtrl.text.trim(), phone: phoneCtrl.text.trim(), role: selectedRole, hospitalId: _needsHospital ? selectedHospitalId : null, isActive: isActive);
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
      title: widget.user == null ? 'Add User' : 'Edit User',
      icon: Icons.manage_accounts_rounded, accent: _accent, width: 520,
      isLoading: isLoading, onCancel: () => Navigator.pop(context), onSubmit: _submit,
      submitLabel: widget.user == null ? 'Create' : 'Update',
      content: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: AdminFormField(controller: firstCtrl, label: 'First name', icon: Icons.person_outline_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Enter first name' : null)),
          const SizedBox(width: 14),
          Expanded(child: AdminFormField(controller: lastCtrl, label: 'Last name', icon: Icons.person_outline_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Enter last name' : null)),
        ]),
        const SizedBox(height: 14),
        AdminFormField(controller: emailCtrl, label: 'Email address', icon: Icons.mail_outline_rounded, enabled: widget.user == null, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.trim().isEmpty ? 'Enter email' : null),
        const SizedBox(height: 14),
        AdminFormField(controller: phoneCtrl, label: 'Phone number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        Text('ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _roleOpts.map((r) {
          final sel = selectedRole == r.value;
          return GestureDetector(
            onTap: () => setState(() => selectedRole = r.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(color: sel ? r.color.withOpacity(0.1) : (isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824)), borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? r.color : (isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)), width: sel ? 1.5 : 1)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(r.icon, size: 14, color: sel ? r.color : (isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))), const SizedBox(width: 6),
                Text(r.label, style: TextStyle(fontSize: 12.5, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? r.color : (isLight ? const Color(0xFF475569) : const Color(0xFF8899AA)))),
              ]),
            ),
          );
        }).toList()),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          value: selectedHospitalId, onChanged: _needsHospital ? (v) => setState(() => selectedHospitalId = v) : null,
          style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
          dropdownColor: isLight ? Colors.white : const Color(0xFF1A1F2E),
          icon: Icon(Icons.unfold_more_rounded, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
          items: [
            DropdownMenuItem<int>(value: null, child: Text('No hospital', style: TextStyle(color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)))),
            ...widget.hospitals.map((h) => DropdownMenuItem<int>(value: h.id, child: Row(children: [Icon(Icons.local_hospital_outlined, size: 14, color: isLight ? const Color(0xFF64748B) : const Color(0xFF64748B)), const SizedBox(width: 8), Text(h.name)]))),
          ],
          validator: (_) => _needsHospital && selectedHospitalId == null ? 'Select a hospital' : null,
          decoration: adminFieldDec('Hospital', Icons.local_hospital_outlined, isLight, accent: _accent),
        ),
        if (widget.user == null) ...[
          const SizedBox(height: 14),
          Text('SECURITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
          const SizedBox(height: 10),
          TextFormField(
            controller: pwCtrl, obscureText: !_pwVisible,
            style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
            validator: (v) { if (v == null || v.trim().isEmpty) return 'Enter password'; if (v.trim().length < 6) return 'Minimum 6 characters'; return null; },
            decoration: adminFieldDec('Password', Icons.lock_outline_rounded, isLight, accent: _accent).copyWith(suffixIcon: IconButton(onPressed: () => setState(() => _pwVisible = !_pwVisible), icon: Icon(_pwVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)))),
          ),
        ],
        const SizedBox(height: 14),
        AdminActiveToggle(value: isActive, onChanged: (v) => setState(() => isActive = v), accent: _accent, activeLabel: 'User account is enabled', inactiveLabel: 'User account is disabled'),
        const SizedBox(height: 4),
      ])),
    );
  }
}