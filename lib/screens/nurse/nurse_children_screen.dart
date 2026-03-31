import 'package:flutter/material.dart';
import '../../models/nurse_child_model.dart';
import '../../services/nurse_service.dart';
import 'nurse_child_records_screen.dart';

class NurseChildrenScreen extends StatefulWidget {
  const NurseChildrenScreen({super.key});

  @override
  State<NurseChildrenScreen> createState() => _NurseChildrenScreenState();
}

class _NurseChildrenScreenState extends State<NurseChildrenScreen>
    with SingleTickerProviderStateMixin {
  final NurseService nurseService = NurseService();
  final TextEditingController searchController = TextEditingController();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool isLoading = true;
  List<NurseChildModel> children = [];
  List<NurseChildModel> filtered = [];

  static const Color _accent = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    loadChildren();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadChildren() async {
    setState(() => isLoading = true);
    try {
      final data = await nurseService.getHospitalChildren();
      if (!mounted) return;
      setState(() { children = data; filtered = data; isLoading = false; });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _snackError('Failed to load children: $e');
    }
  }

  void _applySearch(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      filtered = query.isEmpty ? children : children.where((c) =>
      c.fullName.toLowerCase().contains(query) ||
          (c.parentName ?? '').toLowerCase().contains(query) ||
          c.dateOfBirth.contains(query)
      ).toList();
    });
  }

  void _snackError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text(msg))]),
    backgroundColor: const Color(0xFFE53935),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));

  Future<void> openChild(NurseChildModel child) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => NurseChildRecordsScreen(child: child)));
    await loadChildren();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      color: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(isLight),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _KpiCard(label: 'Total', value: children.length, icon: Icons.groups_rounded, color: _accent, isLight: isLight)),
              const SizedBox(width: 12),
              Expanded(child: _KpiCard(label: 'Active', value: children.where((c) => c.isActive).length, icon: Icons.check_circle_rounded, color: const Color(0xFF00897B), isLight: isLight)),
              const SizedBox(width: 12),
              Expanded(child: _KpiCard(label: 'Inactive', value: children.where((c) => !c.isActive).length, icon: Icons.block_rounded, color: const Color(0xFFE53935), isLight: isLight)),
            ]),
            const SizedBox(height: 20),
            _buildSearchBar(isLight),
            const SizedBox(height: 24),
          ]),
        )),
        if (isLoading)
          SliverFillRemaining(child: Center(child: _PulseLoader(color: _accent)))
        else if (filtered.isEmpty)
          SliverFillRemaining(child: Center(child: _EmptyState(isLight: isLight)))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
              return FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: Offset(0, 0.04 * (i + 1)), end: Offset.zero).animate(_fadeAnim),
                  child: Padding(padding: const EdgeInsets.only(bottom: 10), child: _ChildCard(child: filtered[i], isLight: isLight, onTap: () => openChild(filtered[i]))),
                ),
              );
            }, childCount: filtered.length)),
          ),
      ]),
    );
  }

  Widget _buildHeader(bool isLight) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.child_care_rounded, color: _accent, size: 22)),
        const SizedBox(width: 12),
        Text('Hospital Children', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: isLight ? const Color(0xFF0D1B2A) : Colors.white)),
      ]),
      const SizedBox(height: 6),
      Text('Review and update vaccination records for children at your hospital', style: TextStyle(fontSize: 13.5, color: isLight ? const Color(0xFF6B7A8D) : const Color(0xFF8899AA))),
    ])),
    _OutlineBtn(label: 'Refresh', icon: Icons.refresh_rounded, onTap: loadChildren, isLight: isLight),
  ]);

  Widget _buildSearchBar(bool isLight) => Container(
    decoration: BoxDecoration(
      color: isLight ? Colors.white : const Color(0xFF1A1F2E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      const SizedBox(width: 16),
      Icon(Icons.search_rounded, size: 20, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        controller: searchController, onChanged: _applySearch,
        style: TextStyle(fontSize: 14, color: isLight ? const Color(0xFF0D1B2A) : Colors.white),
        decoration: InputDecoration(hintText: 'Search by name, parent, or date of birth…', hintStyle: TextStyle(fontSize: 14, color: isLight ? const Color(0xFFB0BEC5) : const Color(0xFF4A5568)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16)),
      )),
    ]),
  );
}

class _ChildCard extends StatefulWidget {
  final NurseChildModel child;
  final bool isLight;
  final VoidCallback onTap;
  const _ChildCard({required this.child, required this.isLight, required this.onTap});

  @override
  State<_ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<_ChildCard> {
  bool _hovered = false;
  Color get _gc => widget.child.gender == 'female' ? const Color(0xFFAD1457) : const Color(0xFF1565C0);
  String get _initials => '${widget.child.firstName.isNotEmpty ? widget.child.firstName[0] : ''}${widget.child.lastName.isNotEmpty ? widget.child.lastName[0] : ''}'.toUpperCase();
  String _age(String dob) {
    try { final d = DateTime.parse(dob); final n = DateTime.now(); final m = (n.year - d.year) * 12 + n.month - d.month; return m < 12 ? '$m mo' : '${m ~/ 12} yr${m ~/ 12 > 1 ? 's' : ''}'; }
    catch (_) { return dob; }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.child; final il = widget.isLight;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: il ? Colors.white : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? _gc.withOpacity(0.35) : (il ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
          boxShadow: [BoxShadow(color: _hovered ? _gc.withOpacity(0.1) : Colors.black.withOpacity(0.04), blurRadius: _hovered ? 24 : 10, offset: const Offset(0, 4))],
        ),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: _gc.withOpacity(0.12), shape: BoxShape.circle), child: Center(child: Text(_initials, style: TextStyle(color: _gc, fontWeight: FontWeight.w800, fontSize: 16)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(c.fullName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: il ? const Color(0xFF0D1B2A) : Colors.white)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: _gc.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(c.gender == 'female' ? '♀ Female' : '♂ Male', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _gc))),
              if (!c.isActive) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: il ? const Color(0xFFF1F5F9) : const Color(0xFF252B3B), borderRadius: BorderRadius.circular(6)), child: const Text('Inactive', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)))],
            ]),
            const SizedBox(height: 5),
            Row(children: [
              if (c.parentName != null) ...[Icon(Icons.person_outline_rounded, size: 12, color: il ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), const SizedBox(width: 4), Text(c.parentName!, style: TextStyle(fontSize: 12.5, color: il ? const Color(0xFF64748B) : const Color(0xFF64748B))), const SizedBox(width: 12)],
              Icon(Icons.cake_outlined, size: 12, color: il ? const Color(0xFF94A3B8) : const Color(0xFF4A5568)), const SizedBox(width: 4),
              Text(_age(c.dateOfBirth), style: TextStyle(fontSize: 12.5, color: il ? const Color(0xFF64748B) : const Color(0xFF64748B))),
            ]),
          ])),
          Icon(Icons.chevron_right_rounded, size: 20, color: _hovered ? _gc : (il ? const Color(0xFFCBD5E1) : const Color(0xFF2A3040))),
        ])),
      )),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label; final int value; final IconData icon; final Color color; final bool isLight;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.color, required this.isLight});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    decoration: BoxDecoration(color: isLight ? Colors.white : const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.15)), boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: color, size: 16)),
      const SizedBox(height: 12),
      Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA))),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final bool isLight;
  const _EmptyState({required this.isLight});
  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.08), shape: BoxShape.circle), child: const Icon(Icons.child_care_rounded, size: 44, color: Color(0xFF00695C))),
    const SizedBox(height: 18),
    Text('No children found', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF475569) : const Color(0xFF64748B))),
    const SizedBox(height: 6),
    Text('Try adjusting your search.', style: TextStyle(fontSize: 13.5, color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568))),
  ]);
}

class _PulseLoader extends StatefulWidget {
  final Color color;
  const _PulseLoader({required this.color});
  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}
class _PulseLoaderState extends State<_PulseLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true); _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _a, child: SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(widget.color))));
}

class _OutlineBtn extends StatefulWidget {
  final String label; final IconData icon; final VoidCallback onTap; final bool isLight;
  const _OutlineBtn({required this.label, required this.icon, required this.onTap, required this.isLight});
  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}
class _OutlineBtnState extends State<_OutlineBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(color: _h ? (widget.isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1A1F2E)) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: widget.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B))),
      child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(12), child: InkWell(onTap: widget.onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(widget.icon, size: 16, color: widget.isLight ? const Color(0xFF64748B) : const Color(0xFF8899AA)), const SizedBox(width: 7), Text(widget.label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: widget.isLight ? const Color(0xFF475569) : const Color(0xFF8899AA)))])))),
    ),
  );
}