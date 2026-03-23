import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/settings_confirm_action_dialog.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';

import 'edit_account_screen.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final hasInitialError = provider.error != null && provider.user == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildHeader(context),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: provider.loading && provider.user == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary2,
                      ),
                    )
                  : hasInitialError
                  ? _ErrorState(
                      onRetry: () {
                        context.read<SettingsProvider>().loadSettings();
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        final success = await context
                            .read<SettingsProvider>()
                            .loadSettings();
                        if (!context.mounted || success) return;
                        _showSettingsSnackBar(
                          ScaffoldMessenger.of(context),
                          'تعذر تحديث بيانات الإعدادات بسبب ضعف الاتصال.',
                          isError: true,
                        );
                        context.read<SettingsProvider>().clearError();
                      },
                      color: AppColors.primary2,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSectionTitle('الحساب'),
                            const SizedBox(height: 18),
                            _ActionCard(
                              text: 'تعديل الحساب',
                              icon: Icons.arrow_back_ios_new,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const EditAccountScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Divider(color: AppColors.secondary1, thickness: 1),
                            const SizedBox(height: 24),
                            _buildSectionTitle('الإشعارات'),
                            const SizedBox(height: 10),
                            _NotificationRow(
                              value:
                                  provider.user?.isNotificationsEnabled ??
                                  false,
                              onChanged: provider.togglingNotifications
                                  ? null
                                  : (value) => _onNotificationsChanged(value),
                            ),
                            const SizedBox(height: 10),
                            Divider(color: AppColors.secondary1, thickness: 1),
                            const SizedBox(height: 20),
                            _buildSectionTitle('إدارة الحساب'),
                            const SizedBox(height: 18),
                            _ActionCard(
                              text: 'حذف حساب',
                              icon: Icons.delete_outline,
                              onTap: () {
                                showSettingsConfirmActionDialog(
                                  context: context,
                                  title: 'هل أنت متأكد من حذف الحساب؟',
                                  onConfirm: () async {
                                    await provider.deleteAccount();
                                    if (!context.mounted) return;
                                    _showSettingsSnackBar(
                                      ScaffoldMessenger.of(context),
                                      provider.error ?? 'تم حذف الحساب بنجاح.',
                                      isError: provider.error != null,
                                    );
                                    provider.clearError();
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 15),
                            _ActionCard(
                              text: 'تسجيل خروج',
                              icon: Icons.logout,
                              onTap: () {
                                showSettingsConfirmActionDialog(
                                  context: context,
                                  title: 'هل أنت متأكد من رغبتك بتسجيل الخروج؟',
                                  onConfirm: () async {
                                    final success = await provider.logout();
                                    if (!context.mounted) return;

                                    _showSettingsSnackBar(
                                      ScaffoldMessenger.of(context),
                                      success
                                          ? 'تم تسجيل الخروج بنجاح.'
                                          : (provider.error ??
                                                'تعذر تسجيل الخروج.'),
                                      isError: !success,
                                    );

                                    await Navigator.of(
                                      context,
                                    ).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const SplashScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onNotificationsChanged(bool enabled) async {
    final provider = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.toggleNotifications(enabled);
    if (!mounted) return;

    _showSettingsSnackBar(
      messenger,
      success
          ? (enabled
                ? 'تم تفعيل الإشعارات بنجاح.'
                : 'تم إيقاف الإشعارات بنجاح.')
          : (provider.error ??
                (enabled ? 'تعذر تفعيل الإشعارات.' : 'تعذر إيقاف الإشعارات.')),
      isError: !success,
    );

    if (!success) {
      provider.clearError();
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'الإعدادات',
          style: AppTextStyles.heading5.copyWith(color: AppColors.text_3),
          textAlign: TextAlign.right,
        ),
        IconButton(
          padding: const EdgeInsets.all(15),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(
            Icons.arrow_right_alt_outlined,
            color: AppColors.text_5,
            size: 35,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: AppTextStyles.boldHeading5.copyWith(color: AppColors.text_4),
        textAlign: TextAlign.right,
      ),
    );
  }

  void _showSettingsSnackBar(
    ScaffoldMessengerState messenger,
    String message, {
    bool isError = false,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: AppColors.text_2),
          ),
          backgroundColor: isError
              ? AppColors.backGroundError
              : AppColors.backGroundSuccess,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'تعذر تحميل بيانات الإعدادات.',
                style: AppTextStyles.heading5.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_1,
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.boldSmallText.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _NotificationRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scaleX: 1.2,
          scaleY: 1.1,
          child: Switch(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            value: value,
            activeThumbColor: AppColors.primary2,
            activeTrackColor: AppColors.secondary3,
            trackOutlineColor: const WidgetStatePropertyAll(
              AppColors.secondary1,
            ),
            trackOutlineWidth: const WidgetStatePropertyAll(0.9),
            onChanged: onChanged,
          ),
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'الإشعارات',
            style: AppTextStyles.body,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondary2,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary1,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary2, size: 22),
              ),
              const Spacer(),
              Text(
                text,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text_3,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
