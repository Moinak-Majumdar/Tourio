import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../common/controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // ---------- Content ----------
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar(context),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _glassPanel(
                    scheme: scheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _panelTitle('Appearance'),
                        const SizedBox(height: 16),

                        Obx(() {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _themeButton(
                                scheme: scheme,
                                icon: LucideIcons.smartphone,
                                label: 'System',
                                selected:
                                    controller.themeMode.value ==
                                    AppThemeMode.system,
                                onTap: () =>
                                    controller.changeTheme(AppThemeMode.system),
                              ),
                              _themeButton(
                                scheme: scheme,
                                icon: LucideIcons.sun,
                                label: 'Light',
                                selected:
                                    controller.themeMode.value ==
                                    AppThemeMode.light,
                                onTap: () =>
                                    controller.changeTheme(AppThemeMode.light),
                              ),
                              _themeButton(
                                scheme: scheme,
                                icon: LucideIcons.moon,
                                label: 'Dark',
                                selected:
                                    controller.themeMode.value ==
                                    AppThemeMode.dark,
                                onTap: () =>
                                    controller.changeTheme(AppThemeMode.dark),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _glassPanel(
                    scheme: scheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _PanelInfo(
                          icon: LucideIcons.info,
                          title: 'Tourio',
                          subtitle: 'Offline travel planner',
                        ),
                        SizedBox(height: 14),
                        _PanelInfo(
                          icon: LucideIcons.activity,
                          title: 'Version',
                          subtitle: '1.0.0',
                        ),
                        SizedBox(height: 14),
                        _PanelInfo(
                          icon: LucideIcons.code,
                          title: 'Built by a traveller',
                          subtitle: 'moinak05 🚵',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- App Bar ----------------

  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ---------------- Glass Panel ----------------

  Widget _glassPanel({required Widget child, required ColorScheme scheme}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _panelTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  // ---------------- Theme Button ----------------

  Widget _themeButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ColorScheme scheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.12),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? scheme.primary : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ---------------- Info ----------------

class _PanelInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PanelInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
