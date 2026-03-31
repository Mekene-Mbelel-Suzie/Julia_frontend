import 'package:flutter/material.dart';

class AdminPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget action;

  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

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
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
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
        const SizedBox(width: 16),
        Flexible(child: action),
      ],
    );
  }
}

class AdminSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSearch;
  final Color accent;
  final String buttonLabel;
  final Widget? trailing;

  const AdminSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSearch,
    required this.accent,
    this.buttonLabel = 'Search',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search_rounded,
            color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSearch(),
              style: TextStyle(
                fontSize: 14,
                color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: isLight
                      ? const Color(0xFFB0BEC5)
                      : const Color(0xFF4A5568),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (trailing != null) trailing!,
          Container(
            margin: const EdgeInsets.all(6),
            child: TextButton(
              onPressed: onSearch,
              style: TextButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminCard extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color? hoverAccent;

  const AdminCard({
    super.key,
    this.onTap,
    required this.child,
    this.hoverAccent,
  });

  @override
  State<AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<AdminCard> {
  bool _hovered = false;
  final Color _defaultAccent = const Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = widget.hoverAccent ?? _defaultAccent;

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
              color: _hovered && widget.onTap != null
                  ? accent.withOpacity(0.35)
                  : (isLight
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF252B3B)),
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered && widget.onTap != null
                    ? accent.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _hovered ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class AdminDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Widget content;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitLabel;
  final double width;

  const AdminDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.content,
    required this.isLoading,
    required this.onCancel,
    required this.onSubmit,
    required this.submitLabel,
    this.width = 480,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(isLight),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: content,
              ),
            ),
            _footer(isLight),
          ],
        ),
      ),
    );
  }

  Widget _header(bool isLight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 16, 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLight
                ? const Color(0xFFEEF2F7)
                : const Color(0xFF252B3B),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onCancel,
            icon: Icon(
              Icons.close_rounded,
              color: isLight
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF4A5568),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(bool isLight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isLight
                ? const Color(0xFFEEF2F7)
                : const Color(0xFF252B3B),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: isLoading ? null : onCancel,
            style: TextButton.styleFrom(
              foregroundColor: isLight
                  ? const Color(0xFF64748B)
                  : const Color(0xFF8899AA),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: isLoading ? accent.withOpacity(0.5) : accent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isLoading
                  ? []
                  : [
                BoxShadow(
                  color: accent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: isLoading ? null : onSubmit,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: isLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    submitLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;

  const AdminFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines ?? 1,
      style: TextStyle(
        fontSize: 14,
        color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
      ),
      decoration: adminFieldDec(label, icon, isLight),
    );
  }
}

class AdminActiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;
  final String activeLabel;
  final String inactiveLabel;

  const AdminActiveToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.accent,
    this.activeLabel = 'Record is active',
    this.inactiveLabel = 'Record is inactive',
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B),
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          'Active',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
          ),
        ),
        subtitle: Text(
          value ? activeLabel : inactiveLabel,
          style: TextStyle(
            fontSize: 12,
            color: value
                ? const Color(0xFF00897B)
                : const Color(0xFF94A3B8),
          ),
        ),
        activeColor: accent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }
}

class AdminStatusChip extends StatelessWidget {
  final bool active;

  const AdminStatusChip({
    super.key,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF00897B).withOpacity(0.12)
            : const Color(0xFF94A3B8).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF00897B)
                  : const Color(0xFF94A3B8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: active
                  ? const Color(0xFF00897B)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AdminPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<AdminPrimaryButton> createState() => _AdminPrimaryButtonState();
}

class _AdminPrimaryButtonState extends State<AdminPrimaryButton> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: widget.onTap == null
              ? widget.color.withOpacity(0.4)
              : widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: widget.onTap == null
              ? []
              : [
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

class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 44,
              color: color.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isLight
                  ? const Color(0xFF475569)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isLight
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF4A5568),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AdminLoader extends StatefulWidget {
  final Color color;

  const AdminLoader({
    super.key,
    required this.color,
  });

  @override
  State<AdminLoader> createState() => _AdminLoaderState();
}

class _AdminLoaderState extends State<AdminLoader>
    with SingleTickerProviderStateMixin {
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
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        ),
      ),
    );
  }
}

InputDecoration adminFieldDec(
    String label,
    IconData icon,
    bool isLight, {
      Color accent = const Color(0xFF1565C0),
    }) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontSize: 13.5,
      color: isLight ? const Color(0xFF64748B) : const Color(0xFF4A5568),
    ),
    prefixIcon: Icon(
      icon,
      size: 18,
      color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF4A5568),
    ),
    filled: true,
    fillColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF141824),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(
        color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(
        color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xFFE53935)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(
        color: Color(0xFFE53935),
        width: 1.5,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(
        color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B),
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}