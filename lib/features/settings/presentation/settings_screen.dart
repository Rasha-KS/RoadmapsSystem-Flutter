import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/settings_confirm_action_dialog.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: provider.loading && provider.user == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary2),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 22),
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
                      value: provider.user?.isNotificationsEnabled ?? false,
                      onChanged: (value) {
                        provider.toggleNotifications(value);
                      },
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
                        final messenger = ScaffoldMessenger.of(context);
                        showSettingsConfirmActionDialog(
                          context: context,
                          title: 'هل أنت متأكد من حذف الحساب؟',
                          onConfirm: () async {
                            await provider.deleteAccount();
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                        content:  Directionality(textDirection: TextDirection.rtl, child: Text(
                          "تم حذف الحساب بنجاح (تجريبي)", style:  AppTextStyles.heading5.copyWith(color:AppColors.primary),
                        )),
                        backgroundColor: AppColors.backGroundSuccess,
                        duration: const Duration(seconds: 3),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                      ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    _ActionCard(
                      text: 'تسجيل خروج',
                      icon: Icons.logout,
                      onTap: () {
                        final messenger = ScaffoldMessenger.of(context);
                        showSettingsConfirmActionDialog(
                          context: context,
                          title: 'هل أنت متأكد من رغبتك بتسجيل الخروج؟',
                          onConfirm: () async {
                            await provider.logout();
                            if (!mounted) return;
                            messenger.showSnackBar(
                                SnackBar(
                                  content:  Directionality(textDirection: TextDirection.rtl, child: Text(
                                    "تم تسجيل الخروج بنجاح (تجريبي)", style:  AppTextStyles.heading5.copyWith(color:AppColors.primary),
                                  )),
                                  backgroundColor: AppColors.backGroundSuccess,
                                  duration: const Duration(seconds: 3),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                  ),
                                ),
                            );
                          },
                        );
                      },
                    ),
                    if (provider.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        style: AppTextStyles.smallText.copyWith(color: AppColors.error),
                        textAlign: TextAlign.right,
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الإعدادات',
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.text_3,
              ),
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
        style: AppTextStyles.boldHeading5.copyWith(
          color: AppColors.text_4,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scaleX: 1.2,
          scaleY: 1.1,
          child: Switch(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
          value: value,
          activeThumbColor: AppColors.primary2,
          activeTrackColor: AppColors.secondary3,
          trackOutlineColor: const WidgetStatePropertyAll(AppColors.secondary1),
          trackOutlineWidth: const WidgetStatePropertyAll(0.9),
          onChanged: onChanged,
        ),
        ),
        const Spacer(),
        Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
        child:  Text(
          'الإشعارات',
          style: AppTextStyles.body.copyWith(
            color: AppColors.text_3,
          ),
          textAlign: TextAlign.right,
        ),)
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
                decoration: BoxDecoration(
                  color: AppColors.primary1,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary2,
                  size: 22,
                ),
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
