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
  final _confirmNewPasswordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmNewPasswordFocusNode = FocusNode();

  bool _updatingUsername = false;
  bool _updatingPassword = false;
  bool _updatingPicture = false;
  bool _isCurrentPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmNewPasswordHidden = true;
  String? _pendingLocalImagePath;
  String? _lastSyncedUsername;

  String? _usernameError;
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(_onInputFocusChanged);
    _currentPasswordFocusNode.addListener(_onInputFocusChanged);
    _newPasswordFocusNode.addListener(_onInputFocusChanged);
    _confirmNewPasswordFocusNode.addListener(_onInputFocusChanged);

    final user = context.read<SettingsProvider>().user;
    if (user != null) {
      _usernameController.text = user.username;
      _lastSyncedUsername = user.username;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _usernameFocusNode.removeListener(_onInputFocusChanged);
    _currentPasswordFocusNode.removeListener(_onInputFocusChanged);
    _newPasswordFocusNode.removeListener(_onInputFocusChanged);
    _confirmNewPasswordFocusNode.removeListener(_onInputFocusChanged);
    _usernameFocusNode.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmNewPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SettingsProvider>().user;
    _syncUsernameField(user?.username);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary2,
          onRefresh: _refreshSettings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.text_3,
                    ),
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
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: _buildChangeButton(
                            width: 90,
                            height: 36,
                            radius: 30,
                            loading: _updatingUsername,
                            onPressed: _onChangeUsernamePressed,
                            textStyle: AppTextStyles.body,
                          ),
                        ),
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
                        padding: const EdgeInsets.only(left: 16),
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
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: _updatingPicture
                              ? null
                              : _onPickPicturePressed,
                          child: Stack(
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
                                  child: _buildAvatar(
                                    profileImageUrl: user?.profileImageUrl,
                                    profileImageUpdatedAt: user?.updatedAt,
                                  ),
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
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add_outlined,
                                    size: 17,
                                    color: AppColors.primary2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _SettingsCard(
                  title: 'تغيير كلمة المرور',
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputField(
                          controller: _currentPasswordController,
                          focusNode: _currentPasswordFocusNode,
                          hintText: 'كلمة المرور القديمة',
                          obscureText: _isCurrentPasswordHidden,
                          onToggleObscure: () {
                            setState(() {
                              _isCurrentPasswordHidden =
                                  !_isCurrentPasswordHidden;
                            });
                          },
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
                          obscureText: _isNewPasswordHidden,
                          onToggleObscure: () {
                            setState(() {
                              _isNewPasswordHidden = !_isNewPasswordHidden;
                            });
                          },
                          onChanged: (_) {
                            if (_newPasswordError != null) {
                              setState(() => _newPasswordError = null);
                            }
                            if (_confirmNewPasswordError != null) {
                              setState(() => _confirmNewPasswordError = null);
                            }
                          },
                          errorText: _newPasswordError,
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          controller: _confirmNewPasswordController,
                          focusNode: _confirmNewPasswordFocusNode,
                          hintText: 'تأكيد كلمة المرور الجديدة',
                          obscureText: _isConfirmNewPasswordHidden,
                          onToggleObscure: () {
                            setState(() {
                              _isConfirmNewPasswordHidden =
                                  !_isConfirmNewPasswordHidden;
                            });
                          },
                          onChanged: (_) {
                            if (_confirmNewPasswordError != null) {
                              setState(() => _confirmNewPasswordError = null);
                            }
                          },
                          errorText: _confirmNewPasswordError,
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
    IconData? icon,
    ValueChanged<String>? onChanged,
    String? errorText,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
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
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null) Icon(icon, size: 20, color: borderColor),
              if (onToggleObscure != null && focusNode.hasFocus)
                IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.primary1,
                    size: 20,
                  ),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
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
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.text_3,
                    ),
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

  void _syncUsernameField(String? username) {
    if (username == null ||
        username.isEmpty ||
        _usernameFocusNode.hasFocus ||
        _updatingUsername) {
      return;
    }

    if (_lastSyncedUsername == username &&
        _usernameController.text == username) {
      return;
    }

    _lastSyncedUsername = username;
    _usernameController.value = TextEditingValue(
      text: username,
      selection: TextSelection.collapsed(offset: username.length),
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
          side: const BorderSide(color: AppColors.primary2, width: 0.9),
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
        final success = await provider.updateAccount(username: username);
        if (!mounted) return;

        setState(() {
          _updatingUsername = false;
        });

        if (!success) {
          _showStatusSnack(
            provider.error ?? 'تعذر تغيير اسم المستخدم.',
            isError: true,
          );
          provider.clearError();
          return;
        }

        _usernameFocusNode.unfocus();
        FocusScope.of(context).unfocus();
        _usernameController.text = provider.user?.username ?? username;
        _lastSyncedUsername = _usernameController.text;
        _usernameController.selection = TextSelection.collapsed(
          offset: _usernameController.text.length,
        );
        _showStatusSnack('تم تغيير اسم المستخدم بنجاح.', isError: false);
      },
    );
  }

  Future<void> _onChangePasswordPressed() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmNewPassword = _confirmNewPasswordController.text;

    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmNewPasswordError = null;
    });

    var hasError = false;

    if (currentPassword.isEmpty) {
      _currentPasswordError = 'يرجى إدخال كلمة المرور القديمة';
      hasError = true;
    }

    if (newPassword.isEmpty) {
      _newPasswordError = 'الرجاء إدخال كلمة المرور';
      hasError = true;
    }

    if (confirmNewPassword.isEmpty) {
      _confirmNewPasswordError = 'الرجاء إدخال كلمة المرور';
      hasError = true;
    } else if (confirmNewPassword != newPassword) {
      _confirmNewPasswordError = 'كلمة المرور غير متطابقة';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    await showSettingsConfirmActionDialog(
      context: context,
      title: 'تأكيد تغيير كلمة المرور',
      onConfirm: () async {
        setState(() {
          _updatingPassword = true;
        });

        final provider = context.read<SettingsProvider>();
        final successMessage = await provider.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          newPasswordConfirmation: confirmNewPassword,
        );
        if (!mounted) return;

        setState(() {
          _updatingPassword = false;
        });

        if (successMessage == null) {
          _showStatusSnack(
            provider.error ?? 'تعذر تغيير كلمة المرور.',
            isError: true,
          );
          provider.clearError();
          return;
        }

        _currentPasswordFocusNode.unfocus();
        _newPasswordFocusNode.unfocus();
        _confirmNewPasswordFocusNode.unfocus();
        FocusScope.of(context).unfocus();

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();

        setState(() {
          _isCurrentPasswordHidden = true;
          _isNewPasswordHidden = true;
          _isConfirmNewPasswordHidden = true;
        });

        _showStatusSnack(successMessage, isError: false);
      },
    );
  }

  Future<void> _onChangePicturePressed() async {
    final pendingPath = _pendingLocalImagePath;
    if (pendingPath == null || pendingPath.isEmpty) {
      _showStatusSnack(
        'يرجى اختيار صورة من الصورة الشخصية أولاً.',
        isError: true,
      );
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
        final success = await provider.updateProfileImage(
          localFilePath: pendingPath,
        );
        if (!mounted) return;

        setState(() {
          _updatingPicture = false;
        });

        if (!success) {
          _showStatusSnack(
            provider.error ?? 'تعذر تغيير الصورة الشخصية.',
            isError: true,
          );
          provider.clearError();
          return;
        }

        setState(() {
          _pendingLocalImagePath = null;
        });
        _showStatusSnack('تم تغيير الصورة الشخصية بنجاح.', isError: false);
      },
    );
  }

  Future<void> _onPickPicturePressed() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (pickedFile == null || !mounted) return;

    setState(() {
      _pendingLocalImagePath = pickedFile.path;
    });
  }

  Future<void> _refreshSettings() async {
    final provider = context.read<SettingsProvider>();
    final success = await provider.loadSettings();
    if (!mounted || success) {
      return;
    }

    _showStatusSnack(
      provider.error ?? 'تعذر تحديث بيانات الحساب حالياً.',
      isError: true,
    );
    provider.clearError();
  }

  Widget _buildAvatar({
    required String? profileImageUrl,
    required DateTime? profileImageUpdatedAt,
  }) {
    if (_pendingLocalImagePath != null && _pendingLocalImagePath!.isNotEmpty) {
      return Image.file(File(_pendingLocalImagePath!), fit: BoxFit.cover);
    }
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return _RemoteProfileImage(
        imageUrl: profileImageUrl,
        updatedAt: profileImageUpdatedAt,
      );
    }
    return const Icon(Icons.image_outlined, size: 28, color: _avatarIconColor);
  }

  void _showStatusSnack(String message, {required bool isError}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
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
          backgroundColor: isError
              ? AppColors.error.withValues(alpha: 0.9)
              : AppColors.backGroundSuccess,
          duration: const Duration(seconds: 3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
        ),
      );
  }
}

class _RemoteProfileImage extends StatefulWidget {
  const _RemoteProfileImage({required this.imageUrl, required this.updatedAt});

  final String imageUrl;
  final DateTime? updatedAt;

  @override
  State<_RemoteProfileImage> createState() => _RemoteProfileImageState();
}

class _RemoteProfileImageState extends State<_RemoteProfileImage> {
  late List<String> _candidateUrls;
  var _activeCandidateIndex = 0;
  bool _switchScheduled = false;

  @override
  void initState() {
    super.initState();
    _resetCandidates();
  }

  @override
  void didUpdateWidget(covariant _RemoteProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.updatedAt != widget.updatedAt) {
      _resetCandidates();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_candidateUrls.isEmpty) {
      return _buildFallback();
    }

    return Image.network(
      _candidateUrls[_activeCandidateIndex],
      key: ValueKey(_candidateUrls[_activeCandidateIndex]),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        _tryNextCandidate();
        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    return const Icon(
      Icons.image_outlined,
      size: 28,
      color: _EditAccountScreenState._avatarIconColor,
    );
  }

  void _resetCandidates() {
    _candidateUrls = _buildCandidateUrls(
      widget.imageUrl,
      updatedAt: widget.updatedAt,
    );
    _activeCandidateIndex = 0;
    _switchScheduled = false;
  }

  void _tryNextCandidate() {
    if (_switchScheduled ||
        _activeCandidateIndex >= _candidateUrls.length - 1) {
      return;
    }

    _switchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _activeCandidateIndex++;
        _switchScheduled = false;
      });
    });
  }

  List<String> _buildCandidateUrls(
    String imageUrl, {
    required DateTime? updatedAt,
  }) {
    final normalizedUrl = _appendCacheVersion(imageUrl, updatedAt: updatedAt);
    if (normalizedUrl == null) {
      return const <String>[];
    }

    final candidates = <String>[normalizedUrl];
    final parsed = Uri.tryParse(normalizedUrl);
    if (parsed == null) {
      return candidates;
    }

    final path = parsed.path;
    final isProfilePicturePath = path.contains('/profile_pictures/');
    final alreadyStoragePath = path.startsWith('/storage/');
    if (!isProfilePicturePath || alreadyStoragePath) {
      return candidates;
    }

    final alternateUrl = parsed.replace(path: '/storage$path').toString();
    if (!candidates.contains(alternateUrl)) {
      candidates.add(alternateUrl);
    }
    return candidates;
  }

  String? _appendCacheVersion(String imageUrl, {required DateTime? updatedAt}) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return null;
    }

    if (updatedAt == null) {
      return trimmedUrl;
    }

    final parsed = Uri.tryParse(trimmedUrl);
    if (parsed == null) {
      return trimmedUrl;
    }

    return parsed
        .replace(
          queryParameters: {
            ...parsed.queryParameters,
            'v': updatedAt.toUtc().millisecondsSinceEpoch.toString(),
          },
        )
        .toString();
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              255,
              132,
              159,
              179,
            ).withValues(alpha: 0.7),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              color: AppColors.secondary2,
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text_3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              color: AppColors.secondary4,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
