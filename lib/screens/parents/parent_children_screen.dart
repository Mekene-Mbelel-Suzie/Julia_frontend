import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../services/child_service.dart';
import 'add_child_screen.dart';
import 'child_detail_screen.dart';

class ParentChildrenScreen extends StatefulWidget {
  const ParentChildrenScreen({super.key});

  @override
  State<ParentChildrenScreen> createState() => _ParentChildrenScreenState();
}

class _ParentChildrenScreenState extends State<ParentChildrenScreen>
    with SingleTickerProviderStateMixin {
  final ChildService childService = ChildService();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool isLoading = true;
  List<ChildModel> children = [];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    loadChildren();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> loadChildren() async {
    setState(() => isLoading = true);
    try {
      final data = await childService.getChildren();
      if (!mounted) return;
      setState(() {
        children = data;
        isLoading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showError('Failed to load children: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> openAddChild() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddChildScreen()),
    );
    if (result != null) {
      await loadChildren();
    }
  }

  Future<void> openChild(ChildModel child) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChildDetailScreen(child: child)),
    );
    if (result != null) {
      await loadChildren();
    }
  }

  int get _total => children.length;
  int get _active => children.where((c) => c.isActive).length;
  int get _inactive => children.where((c) => !c.isActive).length;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isLight),
                  const SizedBox(height: 24),
                  _buildKpis(isLight),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: _Loader()),
            )
          else if (children.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: _EmptyState(
                  isLight: isLight,
                  onAdd: openAddChild,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    return FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.04 * (i + 1)),
                          end: Offset.zero,
                        ).animate(_fadeAnim),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChildCard(
                            child: children[i],
                            isLight: isLight,
                            onTap: () => openChild(children[i]),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: children.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF57C00).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.child_care_rounded,
                      color: Color(0xFFF57C00),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Children',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Manage child records and vaccination plans',
                style: TextStyle(
                  fontSize: 13.5,
                  color: isLight
                      ? const Color(0xFF6B7A8D)
                      : const Color(0xFF8899AA),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OutlineBtn(
              label: 'Refresh',
              icon: Icons.refresh_rounded,
              onTap: loadChildren,
              isLight: isLight,
            ),
            const SizedBox(width: 10),
            _PrimaryBtn(
              label: 'Add Child',
              icon: Icons.add_rounded,
              color: const Color(0xFFF57C00),
              onTap: openAddChild,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpis(bool isLight) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Total',
            value: _total,
            icon: Icons.people_rounded,
            color: const Color(0xFFF57C00),
            isLight: isLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'Active',
            value: _active,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF00897B),
            isLight: isLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'Inactive',
            value: _inactive,
            icon: Icons.block_rounded,
            color: const Color(0xFFE53935),
            isLight: isLight,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool isLight;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isLight
                  ? const Color(0xFF64748B)
                  : const Color(0xFF8899AA),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatefulWidget {
  final ChildModel child;
  final bool isLight;
  final VoidCallback onTap;

  const _ChildCard({
    required this.child,
    required this.isLight,
    required this.onTap,
  });

  @override
  State<_ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<_ChildCard> {
  bool _hovered = false;

  Color get _genderColor =>
      widget.child.gender == 'female'
          ? const Color(0xFFAD1457)
          : const Color(0xFF1565C0);

  String get _initials {
    final f = widget.child.firstName;
    final l = widget.child.lastName;
    return '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'.toUpperCase();
  }

  String _age(String dob) {
    try {
      final d = DateTime.parse(dob);
      final now = DateTime.now();
      int months = (now.year - d.year) * 12 + now.month - d.month;
      if (months < 12) return '$months mo';
      return '${months ~/ 12} yr${months ~/ 12 > 1 ? 's' : ''}';
    } catch (_) {
      return dob;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.child;
    final isLight = widget.isLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? _genderColor.withOpacity(0.35)
                  : (isLight
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF252B3B)),
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? _genderColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _hovered ? 24 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _genderColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        color: _genderColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            c.fullName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: isLight
                                  ? const Color(0xFF0D1B2A)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _GenderChip(gender: c.gender, color: _genderColor),
                          const SizedBox(width: 6),
                          if (!c.isActive) _InactiveChip(isLight: isLight),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            size: 12,
                            color: isLight
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF4A5568),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _age(c.dateOfBirth),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isLight
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: isLight
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF4A5568),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            c.dateOfBirth,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isLight
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: _hovered
                      ? _genderColor
                      : (isLight
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF2A3040)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String gender;
  final Color color;

  const _GenderChip({
    required this.gender,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        gender == 'female' ? '♀ Female' : '♂ Male',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InactiveChip extends StatelessWidget {
  final bool isLight;

  const _InactiveChip({required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF252B3B),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isLight;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.isLight,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFF57C00).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.child_care_rounded,
            size: 44,
            color: Color(0xFFF57C00),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'No children yet',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isLight
                ? const Color(0xFF475569)
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Add your first child to start tracking vaccinations.',
          style: TextStyle(
            fontSize: 13.5,
            color: isLight
                ? const Color(0xFF94A3B8)
                : const Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 22),
        _PrimaryBtn(
          label: 'Add Child',
          icon: Icons.add_rounded,
          color: const Color(0xFFF57C00),
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _Loader extends StatefulWidget {
  const _Loader();

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: const SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF57C00)),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PrimaryBtn> createState() => _PrimaryBtnState();
}

class _PrimaryBtnState extends State<_PrimaryBtn> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_h ? 0.35 : 0.2),
              blurRadius: _h ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLight;

  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isLight,
  });

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: _h
              ? (widget.isLight
              ? const Color(0xFFF1F5F9)
              : const Color(0xFF1A1F2E))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isLight
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF252B3B),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.isLight
                        ? const Color(0xFF64748B)
                        : const Color(0xFF8899AA),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: widget.isLight
                          ? const Color(0xFF475569)
                          : const Color(0xFF8899AA),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}