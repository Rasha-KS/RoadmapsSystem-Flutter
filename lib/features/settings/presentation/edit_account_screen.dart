import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  static const Color _avatarIconColor = Color(0xFF9FB3C8);

  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();

  bool _updatingUsername = false;
  bool _updatingPassword = false;
  bool _updatingPicture = false;
  String? _pendingLocalImagePath;

  String? _usernameError;
  String? _currentPasswordError;
  String? _newPasswordError;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(_onInputFocusChanged);
    _currentPasswordFocusNode.addListener(_onInputFocusChanged);
    _newPasswordFocusNode.addListener(_onInputFocusChanged);
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
    _usernameFocusNode.removeListener(_onInputFocusChanged);
    _currentPasswordFocusNode.removeListener(_onInputFocusChanged);
    _newPasswordFocusNode.removeListener(_onInputFocusChanged);
    _usernameFocusNode.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SettingsProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 16),
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
                      focusNode: _usernameFocusNode,
                      hintText: 'اسم مستخدم جديد',
                      icon: Icons.edit_outlined,
                      onChanged: (_) {
                        if (_usernameError != null) {
                          setState(() => _usernameError = null);
                        }
                      },
                      errorText: _usernameError,
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child:Padding(
                        padding: EdgeInsets.only(left: 16),
                        child:  _buildChangeButton(
                        width: 90,
                        height: 36,
                        radius: 30,
                        loading: _updatingUsername,
                        onPressed: _onChangeUsernamePressed,
                        textStyle: AppTextStyles.body,
                      ),)
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _SettingsCard(
                title: 'تغيير الصورة الشخصية',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 16),
                      child: _buildChangeButton(
                      width: 90,
                      height: 36,
                      radius: 18,
                      loading: _updatingPicture,
                      onPressed: _onChangePicturePressed,
                      textStyle: AppTextStyles.body,
                    ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.only(right: 20),
                      child:  GestureDetector(
                      onTap: _updatingPicture ? null : _onPickPicturePressed,
                      child:  Stack(
                      clipBehavior: Clip.none,
                      children: [
                       Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.secondary2,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary1,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: _buildAvatar(user?.profileImageUrl),
                            ),
                        ),
                        
                        Positioned(
                          right: 9,
                          bottom: 2,
                          child: Container(
                            width: 19,
                            height: 19,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary2,
                                width: 2
                              )
                            ),
                            child: const Icon(
                              Icons.add_outlined,
                              size: 17,
                              color: AppColors.primary2,
                            ),
                          ),
                        ),
                      ],
                    ),),)
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _SettingsCard(
                title: 'تغيير كلمة المرور',
                child: Padding(padding: EdgeInsets.only(top:12,bottom: 15 ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputField(
                      controller: _currentPasswordController,
                      focusNode: _currentPasswordFocusNode,
                      hintText: 'كلمة المرور القديمة',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      onChanged: (_) {
                        if (_currentPasswordError != null) {
                          setState(() => _currentPasswordError = null);
                        }
                      },
                      errorText: _currentPasswordError,
                    ),
                    
                    const SizedBox(height: 40),
                    _buildInputField(
                      controller: _newPasswordController,
                      focusNode: _newPasswordFocusNode,
                      hintText: 'كلمة المرور الجديدة',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      onChanged: (_) {
                        if (_newPasswordError != null) {
                          setState(() => _newPasswordError = null);
                        }
                      },
                      errorText: _newPasswordError,
                    ),
                    const SizedBox(height: 50),
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
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    ValueChanged<String>? onChanged,
    String? errorText,
    bool obscureText = false,
  }) {
    final hasError = errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : (focusNode.hasFocus ? AppColors.primary2 : AppColors.primary1);

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
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 20,
                color: borderColor,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
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

  void _onInputFocusChanged() {
    if (!mounted) return;
    setState(() {});
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
    final pendingPath = _pendingLocalImagePath;
    if (pendingPath == null || pendingPath.isEmpty) {
      _showStatusSnack('يرجى اختيار صورة من الصورة الشخصية أولاً', isError: true);
      return;
    }

    await showSettingsConfirmActionDialog(
      context: context,
      title: 'تأكيد تغيير الصورة الشخصية',
      onCancel: () {
        if (!mounted) return;
        setState(() {
          _pendingLocalImagePath = null;
        });
      },
      onConfirm: () async {
        setState(() {
          _updatingPicture = true;
        });
        final provider = context.read<SettingsProvider>();
        await provider.updateProfileImage(localFilePath: pendingPath);
        if (!mounted) return;

        setState(() {
          _updatingPicture = false;
        });

        if (provider.error != null) {
          _showStatusSnack(provider.error!, isError: true);
          return;
        }
        setState(() {
          _pendingLocalImagePath = null;
        });
        _showStatusSnack('تم تغيير الصورة الشخصية بنجاح', isError: false);
      },
    );
  }

  Future<void> _onPickPicturePressed() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null || !mounted) return;

    setState(() {
      _pendingLocalImagePath = pickedFile.path;
    });
  }

  Widget _buildAvatar(String? profileImageUrl) {
    if (_pendingLocalImagePath != null && _pendingLocalImagePath!.isNotEmpty) {
      return Image.file(File(_pendingLocalImagePath!), fit: BoxFit.cover);
    }
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return Image.network(profileImageUrl, fit: BoxFit.cover);
    }
    return const Icon(
      Icons.image_outlined,
      size: 28,
      color: _avatarIconColor,
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

  const _SettingsCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 132, 159, 179).withValues(alpha:0.7),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            /// HEADER
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              color: AppColors.secondary2, // لون الرأس مثل الصورة
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text_3,
                ),
              ),
            ),

            /// BODY
            Container(             
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 26,
              ),
              color: AppColors.secondary4, // لون جسم الكارد
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
