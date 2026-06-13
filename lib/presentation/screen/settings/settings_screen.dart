import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rento/utils/theme/theme_provider.dart';
import 'package:rento/utils/ui_helpers.dart';
import 'package:rento/constants/app_colors.dart';
import 'package:rento/presentation/widget/custom_app_bar.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الإعدادات',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAccountSection(context),
            const SizedBox(height: 16),
            _buildThemeSection(context, themeProvider),
            const SizedBox(height: 16),
            _buildAppSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              icon: Icons.person,
              title: 'الملف الشخصي',
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              icon: Icons.color_lens,
              title: 'المظهر',
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) => themeProvider.toggleTheme(value),
              ),
            ),
            const Divider(),
            _buildSettingsItem(
              context,
              icon: Icons.language,
              title: 'اللغة',
              trailing: const Text('العربية'),
              onTap: () {
                // TODO: Implement language change
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              icon: Icons.backup,
              title: 'نسخ احتياطي',
              onTap: () => _showBackupDialog(context), // ✅ Fixed
            ),


            const Divider(),
            _buildSettingsItem(
              context,
              icon: Icons.info,
              title: 'عن التطبيق',
              onTap: () => _showAboutDialog(context), // ✅ Fixed
            ),
            const Divider(),
            _buildSettingsItem(
              context,
              icon: Icons.help,
              title: 'المساعدة',
              onTap: () {
                // TODO: Implement help
                _showComingSoon(context, 'المساعدة');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نسخ احتياطي'),
        content: const Text('هل ترغب في إنشاء نسخة احتياطية الآن؟'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // Simulate backup process
              Navigator.of(context).pop();
              _showToast(context, 'جاري إنشاء نسخة احتياطية...');
              // TODO: Add real backup logic here (e.g., Firebase, local storage)
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Rento App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shopping_cart),
      applicationLegalese: '© 2025 Rento Inc.',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('تطبيق لإدارة الإيجار والتأجير'),
        )
      ],
    );
  }

  void _showToast(BuildContext context, String message) {
    UIHelpers.showInfoSnackBar(context, message);
  }

  void _showComingSoon(BuildContext context, String feature) {
    UIHelpers.showInfoSnackBar(context, '$feature قادمة قريبًا');
  }

  Widget _buildSettingsItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
      onTap: onTap,
    );
  }
}