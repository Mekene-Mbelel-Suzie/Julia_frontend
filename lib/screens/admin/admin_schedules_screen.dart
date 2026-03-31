import 'package:flutter/material.dart';
import '../../models/vaccine_model.dart';
import '../../models/vaccine_schedule_model.dart';
import '../../services/admin_service.dart';
import 'admin_shared.dart';

class AdminSchedulesScreen extends StatefulWidget {
  const AdminSchedulesScreen({super.key});

  @override
  State<AdminSchedulesScreen> createState() => _AdminSchedulesScreenState();
}

class _AdminSchedulesScreenState extends State<AdminSchedulesScreen>
    with SingleTickerProviderStateMixin {
  final AdminService adminService = AdminService();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool isLoading = true;
  List<VaccineScheduleModel> schedules = [];
  List<VaccineModel> vaccines = [];
  static const Color _accent = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _bootstrap();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => isLoading = true);
    try {
      final vData = await adminService.getVaccines();
      final sData = await adminService.getSchedules();
      if (!mounted) return;
      setState(() {
        vaccines = vData;
        schedules = sData;
        isLoading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Failed to load schedules: $e')),
            ],
          ),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> openForm({VaccineScheduleModel? schedule}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ScheduleFormDialog(
        schedule: schedule,
        vaccines: vaccines,
      ),
    );
    if (result == true) {
      await _bootstrap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      color: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
              child: Column(
                children: [
                  AdminPageHeader(
                    title: 'Schedules',
                    subtitle: 'Define when each vaccine dose should be administered.',
                    icon: Icons.event_note_rounded,
                    accent: _accent,
                    action: AdminPrimaryButton(
                      label: 'Add Schedule',
                      icon: Icons.add_rounded,
                      color: _accent,
                      onTap: vaccines.isEmpty ? null : () => openForm(),
                    ),
                  ),
                  if (vaccines.isEmpty && !isLoading) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Color(0xFFF59E0B),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Add vaccines first before creating schedules.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFF59E0B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: AdminLoader(color: _accent)),
            )
          else if (schedules.isEmpty)
            const SliverFillRemaining(
              child: AdminEmptyState(
                icon: Icons.event_note_outlined,
                title: 'No schedules defined',
                subtitle: 'Create a schedule to define when each dose is administered.',
                color: _accent,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) => FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.04 * (i + 1)),
                        end: Offset.zero,
                      ).animate(_fadeAnim),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ScheduleCard(
                          schedule: schedules[i],
                          isLight: isLight,
                          onEdit: () => openForm(schedule: schedules[i]),
                        ),
                      ),
                    ),
                  ),
                  childCount: schedules.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatefulWidget {
  final VaccineScheduleModel schedule;
  final bool isLight;
  final VoidCallback onEdit;

  const _ScheduleCard({
    required this.schedule,
    required this.isLight,
    required this.onEdit,
  });

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  bool _hov = false;
  static const Color _accent = Color(0xFF00695C);

  String _ageFriendly(int days) {
    if (days == 0) return 'At birth';
    if (days < 30) return '$days day${days == 1 ? '' : 's'}';
    final months = (days / 30.44).round();
    if (months < 12) return '$months month${months == 1 ? '' : 's'}';
    final years = (months / 12).round();
    return '$years year${years == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.schedule;
    final isLight = widget.isLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hov
                ? _accent.withOpacity(0.4)
                : (isLight
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF252B3B)),
          ),
          boxShadow: [
            BoxShadow(
              color: _hov
                  ? _accent.withOpacity(0.1)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _hov ? 24 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'D${s.doseNumber}',
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            s.vaccine.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: isLight
                                  ? const Color(0xFF0D1B2A)
                                  : Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Dose ${s.doseNumber}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AdminStatusChip(active: s.isActive),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        _MetaItem(
                          Icons.schedule_outlined,
                          'At ${_ageFriendly(s.recommendedAgeDays)}',
                          isLight,
                        ),
                        if (s.minAgeDays != null)
                          _MetaItem(
                            Icons.south_rounded,
                            'Min: ${_ageFriendly(s.minAgeDays!)}',
                            isLight,
                          ),
                        if (s.maxAgeDays != null)
                          _MetaItem(
                            Icons.north_rounded,
                            'Max: ${_ageFriendly(s.maxAgeDays!)}',
                            isLight,
                          ),
                      ],
                    ),
                    if ((s.notes ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        s.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isLight
                              ? const Color(0xFF64748B)
                              : const Color(0xFF8899AA),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Tooltip(
                message: 'Edit schedule',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: _hov ? _accent.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    color: _hov
                        ? _accent
                        : (isLight
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF4A5568)),
                    onPressed: widget.onEdit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLight;

  const _MetaItem(this.icon, this.label, this.isLight);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: isLight
                ? const Color(0xFF64748B)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _ScheduleFormDialog extends StatefulWidget {
  final VaccineScheduleModel? schedule;
  final List<VaccineModel> vaccines;

  const _ScheduleFormDialog({
    this.schedule,
    required this.vaccines,
  });

  @override
  State<_ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<_ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService adminService = AdminService();

  late final TextEditingController doseCtrl;
  late final TextEditingController recAgeCtrl;
  late final TextEditingController minAgeCtrl;
  late final TextEditingController maxAgeCtrl;
  late final TextEditingController notesCtrl;

  int? selectedVaccineId;
  bool isActive = true;
  bool isLoading = false;

  static const Color _accent = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    selectedVaccineId = widget.schedule?.vaccine.id;
    doseCtrl = TextEditingController(text: (widget.schedule?.doseNumber ?? 1).toString());
    recAgeCtrl = TextEditingController(text: (widget.schedule?.recommendedAgeDays ?? 0).toString());
    minAgeCtrl = TextEditingController(text: widget.schedule?.minAgeDays?.toString() ?? '');
    maxAgeCtrl = TextEditingController(text: widget.schedule?.maxAgeDays?.toString() ?? '');
    notesCtrl = TextEditingController(text: widget.schedule?.notes ?? '');
    isActive = widget.schedule?.isActive ?? true;
  }

  @override
  void dispose() {
    doseCtrl.dispose();
    recAgeCtrl.dispose();
    minAgeCtrl.dispose();
    maxAgeCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  int? _optInt(String v) => v.trim().isEmpty ? null : int.tryParse(v.trim());

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || selectedVaccineId == null) return;

    setState(() => isLoading = true);

    try {
      if (widget.schedule == null) {
        await adminService.createSchedule(
          vaccineId: selectedVaccineId!,
          doseNumber: int.parse(doseCtrl.text.trim()),
          recommendedAgeDays: int.parse(recAgeCtrl.text.trim()),
          minAgeDays: _optInt(minAgeCtrl.text),
          maxAgeDays: _optInt(maxAgeCtrl.text),
          notes: notesCtrl.text.trim(),
          isActive: isActive,
        );
      } else {
        await adminService.updateSchedule(
          scheduleId: widget.schedule!.id,
          vaccineId: selectedVaccineId!,
          doseNumber: int.parse(doseCtrl.text.trim()),
          recommendedAgeDays: int.parse(recAgeCtrl.text.trim()),
          minAgeDays: _optInt(minAgeCtrl.text),
          maxAgeDays: _optInt(maxAgeCtrl.text),
          notes: notesCtrl.text.trim(),
          isActive: isActive,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AdminDialog(
      title: widget.schedule == null ? 'Add Schedule' : 'Edit Schedule',
      icon: Icons.event_note_rounded,
      accent: _accent,
      width: 520,
      isLoading: isLoading,
      onCancel: () => Navigator.pop(context),
      onSubmit: _submit,
      submitLabel: widget.schedule == null ? 'Create' : 'Update',
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedVaccineId,
              onChanged: (v) => setState(() => selectedVaccineId = v),
              style: TextStyle(
                fontSize: 14,
                color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
              ),
              dropdownColor: isLight ? Colors.white : const Color(0xFF1A1F2E),
              icon: Icon(
                Icons.unfold_more_rounded,
                size: 18,
                color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568),
              ),
              items: widget.vaccines
                  .map(
                    (v) => DropdownMenuItem<int>(
                  value: v.id,
                  child: Row(
                    children: [
                      const Icon(Icons.vaccines_outlined, size: 14),
                      const SizedBox(width: 8),
                      Flexible(child: Text('${v.name} (${v.code})')),
                    ],
                  ),
                ),
              )
                  .toList(),
              validator: (v) => v == null ? 'Select a vaccine' : null,
              decoration: adminFieldDec(
                'Vaccine',
                Icons.vaccines_outlined,
                isLight,
                accent: _accent,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    controller: doseCtrl,
                    label: 'Dose number',
                    icon: Icons.format_list_numbered_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AdminFormField(
                    controller: recAgeCtrl,
                    label: 'Recommended age (days)',
                    icon: Icons.schedule_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    controller: minAgeCtrl,
                    label: 'Min age (days)',
                    icon: Icons.south_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AdminFormField(
                    controller: maxAgeCtrl,
                    label: 'Max age (days)',
                    icon: Icons.north_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AdminFormField(
              controller: notesCtrl,
              label: 'Notes (optional)',
              icon: Icons.note_alt_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            AdminActiveToggle(
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
              accent: _accent,
              activeLabel: 'Active — used in vaccination plan generation',
              inactiveLabel: 'Inactive — excluded from plan generation',
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}