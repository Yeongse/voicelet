import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../profile/services/profile_api_service.dart';
import '../../search/providers/username_check_provider.dart';

/// オンボーディング画面（新規ユーザー向けプロフィール入力）
/// 表示名は必須。プロフィール登録完了後にDBにユーザーが永続化される。
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  int? _selectedYear;
  int? _selectedMonth;

  final _imagePicker = ImagePicker();
  XFile? _selectedImage;

  bool _isLoading = false;
  String? _error;
  Timer? _usernameDebounce;

  // 画面生成時にUUIDを生成（アバターファイル名に使用）
  late final String _avatarUuid;

  @override
  void initState() {
    super.initState();
    _avatarUuid = const Uuid().v4();
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
      if (username.length >= 3) {
        ref.read(usernameCheckProvider.notifier).check(username);
      } else {
        ref.read(usernameCheckProvider.notifier).reset();
      }
    });
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? birthMonth;
      if (_selectedYear != null && _selectedMonth != null) {
        birthMonth =
            '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';
      }

      final profileService = ProfileApiService();
      final username = _usernameController.text.trim().replaceAll(RegExp(r'^@'), '');

      // プロフィールを新規登録（POST）してユーザーをDBに永続化
      var profile = await profileService.registerProfile(
        username: username,
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        birthMonth: birthMonth,
      );

      // アバターをアップロード（任意）
      if (_selectedImage != null) {
        try {
          final extension = _selectedImage!.path.split('.').last.toLowerCase();
          String contentType;
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              break;
            case 'png':
              contentType = 'image/png';
              break;
            case 'webp':
              contentType = 'image/webp';
              break;
            default:
              throw Exception('サポートされていないファイル形式です');
          }

          final file = File(_selectedImage!.path);
          final fileSize = await file.length();

          // ファイル名を生成（uuid_timestamp形式）
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = '${_avatarUuid}_$timestamp';

          // 署名付きURLを取得
          final urlData = await profileService.getAvatarUploadUrl(
            contentType: contentType,
            fileSize: fileSize,
            fileName: fileName,
          );

          // Cloud Storageにアップロード
          await profileService.uploadAvatar(
            uploadUrl: urlData['uploadUrl']!,
            imageFile: file,
            contentType: contentType,
          );

          // プロフィールを更新してavatarPathを保存し、更新後のプロフィールを取得
          profile = await profileService.updateProfile(
            avatarPath: urlData['avatarPath'],
          );
        } catch (e) {
          // アバターのアップロードに失敗してもプロフィール登録は成功とする
          debugPrint('Avatar upload failed: $e');
        }
      }

      // 認証状態を更新（アバターを含む最新のプロフィールを使用）
      await ref.read(authProvider.notifier).completeOnboarding(profile);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景画像
          Image.asset(
            'assets/main_background.png',
            fit: BoxFit.cover,
          ),
          // グラデーションオーバーレイ
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          // コンテンツ
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // タイトル
                    Text(
                      'プロフィールを設定',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'あなたのことを教えてください',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // アバター選択
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppTheme.bgSecondary,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(File(_selectedImage!.path))
                                  : null,
                              child: _selectedImage == null
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: AppTheme.textSecondary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.accentPrimary,
                                child: Icon(
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

                    // ユーザー名（必須）
                    _buildInputLabel('ユーザー名 *'),
                    const SizedBox(height: 8),
                    _buildUsernameField(),
                    const SizedBox(height: 16),

                    // 表示名（必須）
                    _buildInputLabel('表示名 *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: _buildInputDecoration(
                        hintText: 'ニックネームを入力',
                      ),
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '表示名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 自己紹介（任意）
                    _buildInputLabel('自己紹介（任意）'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: _buildInputDecoration(
                        hintText: 'あなたについて教えてください',
                      ),
                      maxLength: 500,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // 生年月（任意）
                    _buildInputLabel('生年月（任意）'),
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
                    Text(
                      '年齢として表示されます',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // エラーメッセージ
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 完了ボタン
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 4,
                          shadowColor:
                              AppTheme.accentPrimary.withValues(alpha: 0.4),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '始める',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
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
              return 'ユーザー名を入力してください';
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

  Widget _buildInputLabel(String label) {
    return Text(
      label,
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
      hintStyle: TextStyle(color: AppTheme.textSecondary),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
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
        borderSide: const BorderSide(color: Colors.red),
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
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: AppTheme.textSecondary),
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
