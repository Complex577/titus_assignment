import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../viewmodels/history_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _sectionHeader(context, AppStrings.appearance),
          _tile(
            context,
            icon: Icons.dark_mode_outlined,
            title: AppStrings.darkMode,
            subtitle: settings.isDarkMode
                ? AppStrings.darkModeEnabledDesc
                : AppStrings.lightModeEnabledDesc,
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: settings.setDarkMode,
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _sectionHeader(context, AppStrings.data),
          _tile(
            context,
            icon: Icons.delete_sweep_outlined,
            title: AppStrings.clearHistory,
            subtitle: AppStrings.clearHistoryDesc,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _confirmClearAll(context),
          ),
          const SizedBox(height: 8),
          _sectionHeader(context, AppStrings.about),
          _tile(
            context,
            icon: Icons.info_outline,
            title: AppStrings.aboutTitle,
            subtitle: '${AppStrings.version} - ${AppStrings.aboutDesc}',
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              AppStrings.version,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                )
              : null,
          trailing: trailing,
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.clearConfirmTitle),
        content: const Text(AppStrings.clearConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppStrings.clearAll,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<HistoryViewModel>().clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.historyCleared)),
        );
      }
    }
  }
}
