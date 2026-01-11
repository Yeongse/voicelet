import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  int? _selectedYear;
  int? _selectedMonth;

  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileAsync = await ref.read(myProfileProvider.future);
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
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
            content: const Text('アバターを更新しました'),
            backgroundColor: AppTheme.success,
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

    final success = await ref.read(profileUpdateProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      birthMonth: birthMonth,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('プロフィールを更新しました'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.pop();
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'アカウント削除',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'アカウントを削除すると、すべてのデータが失われます。この操作は取り消せません。\n\n本当に削除しますか？',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'キャンセル',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '削除する',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(profileUpdateProvider.notifier).deleteAccount();
      if (success && mounted) {
        context.go('/');
      }
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

                // アカウント削除
                const SizedBox(height: 48),
                Divider(color: AppTheme.textTertiary.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _deleteAccount,
                    child: Text(
                      'アカウントを削除',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ),
                ),
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
