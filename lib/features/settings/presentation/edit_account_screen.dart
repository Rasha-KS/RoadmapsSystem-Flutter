import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/settings_confirm_action_dialog.dart';
import 'settings_provider.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _updatingUsername = false;
  bool _updatingPassword = false;
  bool _updatingPicture = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<SettingsProvider>().settings?.user;
    if (user != null) {
      _usernameController.text = user.username;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SettingsProvider>().settings?.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 8),
              Text(
                'الإعدادات',
                textAlign: TextAlign.right,
                style: AppTextStyles.heading5.copyWith(
                  color: AppColors.text_3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تعديل الحساب',
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary2,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                title: 'تغيير اسم المستخدم',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _usernameController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'أدخل اسم مستخدم جديد',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_4),
                        filled: true,
                        fillColor: AppColors.secondary4,
                        suffixIcon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChangeButton(
                      loading: _updatingUsername,
                      onPressed: _onChangeUsernamePressed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'تغيير صورة الملف الشخصي',
                child: Row(
                  children: [
                    Expanded(
                      child: _buildChangeButton(
                        loading: _updatingPicture,
                        onPressed: _onChangePicturePressed,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.secondary2,
                          backgroundImage: user?.profileImageUrl != null
                              ? NetworkImage(user!.profileImageUrl!)
                              : null,
                          child: user?.profileImageUrl == null
                              ? const Icon(
                                  Icons.person_outline,
                                  color: AppColors.primary,
                                  size: 28,
                                )
                              : null,
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary2,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 14,
                              color: AppColors.text_2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'تغيير كلمة المرور',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور الحالية',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_4),
                        filled: true,
                        fillColor: AppColors.secondary4,
                        suffixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور الجديدة',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_4),
                        filled: true,
                        fillColor: AppColors.secondary4,
                        suffixIcon: const Icon(
                          Icons.enhanced_encryption_outlined,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChangeButton(
                      loading: _updatingPassword,
                      onPressed: _onChangePasswordPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'الإعدادات',
          style: AppTextStyles.heading5.copyWith(
            color: AppColors.text_3,
            fontWeight: FontWeight.w500,
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

  Widget _buildChangeButton({
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary2,
          foregroundColor: AppColors.text_2,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'تغيير',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _onChangeUsernamePressed() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      _showSnack('يرجى إدخال اسم مستخدم');
      return;
    }

    await showSettingsConfirmActionDialog(
      context: context,
      title: 'تأكيد تغيير اسم المستخدم',
      onConfirm: () async {
        setState(() => _updatingUsername = true);
        final provider = context.read<SettingsProvider>();
        await provider.updateAccount(username: username);
        if (!mounted) return;
        setState(() => _updatingUsername = false);

        if (provider.error != null) {
          _showSnack(provider.error!);
          return;
        }
        _showSnack('تم تغيير اسم المستخدم بنجاح');
      },
    );
  }

  Future<void> _onChangePasswordPressed() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      _showSnack('يرجى إدخال كلمة المرور الحالية');
      return;
    }
    if (newPassword.isEmpty) {
      _showSnack('يرجى إدخال كلمة المرور الجديدة');
      return;
    }
    if (newPassword.length < 6) {
      _showSnack('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    await showSettingsConfirmActionDialog(
      context: context,
      title: 'تأكيد تغيير كلمة المرور',
      onConfirm: () async {
        setState(() => _updatingPassword = true);
        final provider = context.read<SettingsProvider>();
        await provider.updateAccount(password: newPassword);
        if (!mounted) return;
        setState(() => _updatingPassword = false);

        if (provider.error != null) {
          _showSnack(provider.error!);
          return;
        }

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _showSnack('تم تغيير كلمة المرور بنجاح');
      },
    );
  }

  Future<void> _onChangePicturePressed() async {
    await showSettingsConfirmActionDialog(
      context: context,
      title: 'تأكيد تغيير الصورة الشخصية',
      onConfirm: () async {
        setState(() => _updatingPicture = true);
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        setState(() => _updatingPicture = false);
        _showSnack('تغيير الصورة غير مرتبط بمصدر بيانات بعد');
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent_3,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text_1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
