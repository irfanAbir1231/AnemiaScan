import '../water_ui/water_ui.dart';
import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';

enum NavTab { home, history, help }

/// Bottom nav bar shared by Home + History screens.
class AppBottomNav extends StatelessWidget {
  final NavTab active;
  final VoidCallback onHome;
  final VoidCallback onHistory;
  final VoidCallback onHelp;

  const AppBottomNav({
    super.key,
    required this.active,
    required this.onHome,
    required this.onHistory,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B5964), Color(0xFF117985), Color(0xFF0C6570)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06343B).withValues(alpha: 0.34),
              blurRadius: 26,
              offset: const Offset(0, 11),
            ),
            const BoxShadow(color: Colors.white24, offset: Offset(0, -1)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: S.navHome,
                active: active == NavTab.home,
                onTap: onHome,
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: S.navHistory,
                active: active == NavTab.history,
                onTap: onHistory,
              ),
              _NavItem(
                icon: Icons.help_outline_rounded,
                label: S.navHelp,
                active: false,
                onTap: onHelp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: WaterNavItem(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: .18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: active ? Border.all(color: Colors.white30) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? Colors.white : Colors.white70,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round back / close button used on capture, result, history headers.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;
  final Color? borderColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.background = AppColors.white,
    this.iconColor = AppColors.ink,
    this.borderColor = AppColors.cardEdge,
  });

  @override
  Widget build(BuildContext context) {
    return WaterButton(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}
