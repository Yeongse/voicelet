import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../legal_content.dart';

enum LegalDocumentType {
  privacyPolicy,
  termsOfService,
}

/// 法的文書（プライバシーポリシー・利用規約）を表示するページ
class LegalPage extends StatelessWidget {
  final LegalDocumentType type;

  const LegalPage({super.key, required this.type});

  String get _title {
    switch (type) {
      case LegalDocumentType.privacyPolicy:
        return 'プライバシーポリシー';
      case LegalDocumentType.termsOfService:
        return '利用規約';
    }
  }

  String get _content {
    switch (type) {
      case LegalDocumentType.privacyPolicy:
        return privacyPolicyContent;
      case LegalDocumentType.termsOfService:
        return termsOfServiceContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        foregroundColor: AppTheme.textPrimary,
        title: Text(_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _content,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
