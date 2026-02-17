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
  static const Color _cardColor = Color(0xFFC9D7E3);
  static const Color _avatarBgColor = Color(0xFFDCE6EF);
  static const Color _avatarIconColor = Color(0xFF9FB3C8);

  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _updatingUsername = false;
  bool _updatingPassword = false;
  bool _updatingPicture = false;

  String? _usernameError;
  String? _currentPasswordError;
  String? _newPasswordError;

  @override
  void initState() {
    super.initState();
    final user = context.read<SettingsProvider>().user;
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
    final user = context.watch<SettingsProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 12),
                child: Text(
                  'تعديل الحساب',
                  style: AppTextStyles.heading5.copyWith(color: AppColors.text_3),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 15),
              _SettingsCard(
                title: 'تغيير اسم المستخدم',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputField(
                      controller: _usernameController,
                      hintText: 'اسم مستخدم جديد',
                      icon: Icons.edit_outlined,
                      onChanged: (_) {
                        if (_usernameError != null) {
                          setState(() => _usernameError = null);
                        }
                      },
                      errorText: _usernameError,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildChangeButton(
                        width: 90,
                        height: 36,
                        radius: 30,
                        loading: _updatingUsername,
                        onPressed: _onChangeUsernamePressed,
                        textStyle: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
              _SettingsCard(
                title: 'تغيير الصورة الشخصية',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildChangeButton(
                      width: 90,
                      height: 36,
                      radius: 18,
                      loading: _updatingPicture,
                      onPressed: _onChangePicturePressed,
                      textStyle: AppTextStyles.body,
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: _avatarBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary1,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: user?.profileImageUrl != null
                                ? Image.network(
                                    user!.profileImageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.image_outlined,
                                    size: 28,
                                    color: _avatarIconColor,
                                  ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF4B183),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _SettingsCard(
                title: 'تغيير كلمة المرور',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputField(
                      controller: _currentPasswordController,
                      hintText: 'كلمة مرور قديمة',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      onChanged: (_) {
                        if (_currentPasswordError != null) {
                          setState(() => _currentPasswordError = null);
                        }
                      },
                      errorText: _currentPasswordError,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: _newPasswordController,
                      hintText: 'كلمة مرور جديدة',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      onChanged: (_) {
                        if (_newPasswordError != null) {
                          setState(() => _newPasswordError = null);
                        }
                      },
                      errorText: _newPasswordError,
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.center,
                      child: _buildChangeButton(
                        width: 140,
                        height: 40,
                        radius: 20,
                        loading: _updatingPassword,
                        onPressed: _onChangePasswordPressed,
                        textStyle: AppTextStyles.heading5,
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    ValueChanged<String>? onChanged,
    String? errorText,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: errorText == null ? AppColors.primary1 : AppColors.error,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 20,
                color: errorText == null ? AppColors.primary1 : AppColors.error,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  obscureText: obscureText,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_3),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              errorText,
              textAlign: TextAlign.right,
              style: AppTextStyles.smallText.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChangeButton({
    required double width,
    required double height,
    required double radius,
    required bool loading,
    required VoidCallback onPressed,
    required TextStyle textStyle,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: MaterialButton(
        onPressed: loading ? null : onPressed,
        color: AppColors.buttonLoginSignUp,
        disabledColor: AppColors.buttonLoginSignUp.withValues(alpha: 0.5),
        elevation: 2,
        height: height,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
            color: AppColors.primary2,
            width: 0.9,
          ),
        ),
        child: loading
            ? SizedBox(
                width: height * 0.5,
                height: height * 0.5,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary2,
                ),
              )
            : Text('تغيير', style: textStyle.copyWith(color: AppColors.text_3)),
      ),
    );
  }

  Future<void> _onChangeUsernamePressed() async {
    final username = _usernameController.text.trim();

    setState(() {
      _usernameError = null;
    });

    if (username.isEmpty) {
      setState(() {
        _usernameError = 'يرجى إدخال اسم مستخدم';
      });
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

        setState(() {
          _updatingUsername = false;
        });

        if (provider.error != null) {
          _showStatusSnack(provider.error!, isError: true);
          return;
        }
        _showStatusSnack('تم تغيير اسم المستخدم بنجاح', isError: false);
      },
    );
  }

  Future<void> _onChangePasswordPressed() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
    });

    if (currentPassword.isEmpty) {
      setState(() {
        _currentPasswordError = 'يرجى إدخال كلمة المرور الحالية';
      });
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = 'يرجى إدخال كلمة المرور الجديدة';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _newPasswordError = 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل';
      });
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

        setState(() {
          _updatingPassword = false;
        });

        if (provider.error != null) {
          _showStatusSnack(provider.error!, isError: true);
          return;
        }
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _showStatusSnack('تم تغيير كلمة المرور بنجاح', isError: false);
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

        setState(() {
          _updatingPicture = false;
        });
        _showStatusSnack('تغيير الصورة غير مرتبط بمصدر بيانات بعد', isError: true);
      },
    );
  }

  void _showStatusSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
            style: AppTextStyles.heading5.copyWith(
              color: isError ? AppColors.text_2 : AppColors.primary,
            ),
          ),
        ),
        backgroundColor:
            isError ? AppColors.error.withValues(alpha: 0.9) : AppColors.backGroundSuccess,
        duration: const Duration(seconds: 3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _EditAccountScreenState._cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3A4A),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

