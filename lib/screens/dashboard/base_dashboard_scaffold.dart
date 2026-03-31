import 'package:flutter/material.dart';
import '../../models/app_user.dart';

class DashboardShell extends StatelessWidget {
  final String role;
  final Color accentColor;
  final AppUser user;
  final List<(IconData, IconData, String)> navItems;
  final int selectedIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  final Widget child;

  const DashboardShell({
    super.key,
    required this.role,
    required this.accentColor,
    required this.user,
    required this.navItems,
    required this.selectedIndex,
    required this.onNavTap,
    required this.onRefresh,
    required this.onLogout,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
      body: Row(
        children: [
          _SideNav(
            accent: accentColor,
            role: role,
            user: user,
            items: navItems,
            selectedIndex: selectedIndex,
            onTap: onNavTap,
            onRefresh: onRefresh,
            onLogout: onLogout,
            isLight: isLight,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final Color accent;
  final String role;
  final AppUser user;
  final List<(IconData, IconData, String)> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  final bool isLight;

  const _SideNav({
    required this.accent,
    required this.role,
    required this.user,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.onRefresh,
    required this.onLogout,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF141824),
        border: Border(
          right: BorderSide(
            color: isLight ? const Color(0xFFE8EDF2) : const Color(0xFF1E2535),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_information_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JULIA',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: accent,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E2535),
            height: 1,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final (idleIcon, activeIcon, label) = items[i];
                final selected = selectedIndex == i;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? accent.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? activeIcon : idleIcon,
                              size: 18,
                              color: selected
                                  ? accent
                                  : (isLight
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF4A5568)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                color: selected
                                    ? accent
                                    : (isLight
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF8899AA)),
                              ),
                            ),
                            if (selected) ...[
                              const Spacer(),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
            color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E2535),
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _NavAction(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onTap: onRefresh,
                  isLight: isLight,
                ),
                const SizedBox(height: 4),
                _NavAction(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  onTap: onLogout,
                  isLight: isLight,
                  color: const Color(0xFFE53935),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF252B3B),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: accent.withOpacity(0.15),
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLight ? const Color(0xFF0D1B2A) : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF94A3B8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLight;
  final Color? color;

  const _NavAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isLight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 15, color: c),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: c,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeBanner extends StatelessWidget {
  final AppUser user;
  final Color accent;
  final String subtitle;

  const WelcomeBanner({
    super.key,
    required this.user,
    required this.accent,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, Color.lerp(accent, Colors.black, 0.25)!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashInfoRow(Icons.badge_outlined, user.role),
                const SizedBox(height: 6),
                DashInfoRow(Icons.mail_outline_rounded, user.email),
                if (user.hospital?['name'] != null) ...[
                  const SizedBox(height: 6),
                  DashInfoRow(Icons.local_hospital_outlined, user.hospital!['name']),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const DashInfoRow(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}