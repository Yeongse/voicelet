import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../search/providers/username_check_provider.dart';
import '../providers/profile_provider.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  int? _selectedYear;
  int? _selectedMonth;
  bool _isPrivate = false;
  Timer? _usernameDebounce;
  String? _originalUsername;

  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileAsync = await ref.read(myProfileProvider.future);
    _usernameController.text = profileAsync.username ?? '';
    _originalUsername = profileAsync.username;
    _nameController.text = profileAsync.name ?? '';
    _bioController.text = profileAsync.bio ?? '';

    if (profileAsync.birthMonth != null) {
      final parts = profileAsync.birthMonth!.split('-');
      if (parts.length == 2) {
        setState(() {
          _selectedYear = int.tryParse(parts[0]);
          _selectedMonth = int.tryParse(parts[1]);
        });
      }
    }

    setState(() {
      _isPrivate = profileAsync.isPrivate;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameDebounce?.cancel();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      final username = value.replaceAll(RegExp(r'^@'), '');
      if (username != _originalUsername && username.length >= 3) {
        ref.read(usernameCheckProvider.notifier).check(username);
      } else {
        ref.read(usernameCheckProvider.notifier).reset();
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      final success = await ref.read(profileUpdateProvider.notifier).uploadAvatar(image);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'アバターを更新しました',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            backgroundColor: AppTheme.bgElevated,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    String? birthMonth;
    if (_selectedYear != null && _selectedMonth != null) {
      birthMonth = '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';
    }

    final username = _usernameController.text.trim().replaceAll(RegExp(r'^@'), '');

    final success = await ref.read(profileUpdateProvider.notifier).updateProfile(
      username: username.isNotEmpty && username != _originalUsername ? username : null,
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      birthMonth: birthMonth,
      isPrivate: _isPrivate,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'プロフィールを更新しました',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          backgroundColor: AppTheme.bgElevated,
        ),
      );
      context.pop();
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.textPrimary),
              title: Text(
                'カメラで撮影',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.textPrimary),
              title: Text(
                'ギャラリーから選択',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final updateState = ref.watch(profileUpdateProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        foregroundColor: AppTheme.textPrimary,
        title: const Text('プロフィール編集'),
        actions: [
          TextButton(
            onPressed: updateState.isLoading ? null : _save,
            child: updateState.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accentPrimary,
                    ),
                  )
                : Text(
                    '保存',
                    style: TextStyle(
                      color: AppTheme.accentPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // アバター
                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.gradientAccent,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.bgSecondary,
                            ),
                            child: ClipOval(
                              child: profile.avatarUrl != null
                                  ? Image.network(
                                      profile.avatarUrl!,
                                      fit: BoxFit.cover,
                                      width: 114,
                                      height: 114,
                                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.accentPrimary,
                                          ),
                                        );
                                      },
                                    )
                                  : _buildDefaultAvatar(),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.gradientAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentPrimary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ユーザー名
                _buildLabel('ユーザー名'),
                const SizedBox(height: 8),
                _buildUsernameField(),
                const SizedBox(height: 16),

                // 表示名
                _buildLabel('表示名 *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: _buildInputDecoration(hintText: 'あなたの名前'),
                  maxLength: 100,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '表示名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 自己紹介
                _buildLabel('自己紹介'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: _buildInputDecoration(hintText: 'あなたについて教えてください'),
                  maxLength: 500,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),

                // 生年月
                _buildLabel('生年月'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown<int>(
                        value: _selectedYear,
                        hint: '年',
                        items: List.generate(100, (index) {
                          final year = DateTime.now().year - index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text('$year'),
                          );
                        }),
                        onChanged: (value) {
                          setState(() => _selectedYear = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown<int>(
                        value: _selectedMonth,
                        hint: '月',
                        items: List.generate(12, (index) {
                          final month = index + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Text('$month'),
                          );
                        }),
                        onChanged: (value) {
                          setState(() => _selectedMonth = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '年齢として表示されます',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // 非公開設定
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.textTertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '非公開アカウント',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'オンにすると、フォローリクエストを承認したユーザーのみがフォローできます',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isPrivate,
                        onChanged: (value) {
                          setState(() => _isPrivate = value);
                        },
                        activeTrackColor: AppTheme.accentPrimary.withValues(alpha: 0.5),
                        activeThumbColor: AppTheme.accentPrimary,
                      ),
                    ],
                  ),
                ),

                // エラーメッセージ
                if (updateState.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      updateState.error!,
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ),
                ],

              ],
            ),
          ),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(color: AppTheme.accentPrimary),
        ),
        error: (error, _) => Center(
          child: Text(
            'エラー: $error',
            style: TextStyle(color: AppTheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 114,
      height: 114,
      color: AppTheme.bgTertiary,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 60,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    final usernameCheck = ref.watch(usernameCheckProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _usernameController,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: _buildInputDecoration(hintText: 'username').copyWith(
            prefixText: '@',
            prefixStyle: TextStyle(color: AppTheme.textSecondary),
            suffixIcon: _buildUsernameSuffix(usernameCheck),
          ),
          maxLength: 30,
          onChanged: _onUsernameChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return null; // Optional field
            }
            final username = value.replaceAll(RegExp(r'^@'), '');
            if (username.length < 3) {
              return 'ユーザー名は3文字以上です';
            }
            if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(username)) {
              return '半角英数字、アンダースコア、ピリオドのみ使用できます';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          _getUsernameHintText(usernameCheck),
          style: TextStyle(
            fontSize: 12,
            color: _getUsernameHintColor(usernameCheck),
          ),
        ),
      ],
    );
  }

  String _getUsernameHintText(UsernameAvailability state) {
    switch (state) {
      case UsernameAvailability.checking:
        return '確認中...';
      case UsernameAvailability.available:
        return 'このユーザー名は使用可能です';
      case UsernameAvailability.unavailable:
        return 'このユーザー名は既に使用されています';
      case UsernameAvailability.invalid:
        return '無効なユーザー名です';
      case UsernameAvailability.unknown:
        return '半角英数字、アンダースコア、ピリオドのみ使用できます';
    }
  }

  Color _getUsernameHintColor(UsernameAvailability state) {
    switch (state) {
      case UsernameAvailability.available:
        return AppTheme.success;
      case UsernameAvailability.unavailable:
      case UsernameAvailability.invalid:
        return AppTheme.error;
      case UsernameAvailability.checking:
      case UsernameAvailability.unknown:
        return AppTheme.textSecondary;
    }
  }

  Widget? _buildUsernameSuffix(UsernameAvailability state) {
    switch (state) {
      case UsernameAvailability.checking:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.accentPrimary,
            ),
          ),
        );
      case UsernameAvailability.available:
        return Icon(Icons.check_circle, color: AppTheme.success);
      case UsernameAvailability.unavailable:
      case UsernameAvailability.invalid:
        return Icon(Icons.cancel, color: AppTheme.error);
      case UsernameAvailability.unknown:
        return null;
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppTheme.textTertiary),
      filled: true,
      fillColor: AppTheme.bgSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.textTertiary.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.textTertiary.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.accentPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.error),
      ),
      counterStyle: TextStyle(color: AppTheme.textSecondary),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textTertiary.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: AppTheme.textTertiary),
          ),
          isExpanded: true,
          dropdownColor: AppTheme.bgSecondary,
          style: TextStyle(color: AppTheme.textPrimary),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
