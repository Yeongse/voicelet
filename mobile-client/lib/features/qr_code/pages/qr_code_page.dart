import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/qr_display_tab.dart';
import '../widgets/qr_scanner_tab.dart';

/// QRコード機能のメイン画面
/// 「自分のQRコード表示」と「スキャン」の2つのタブを持つ
class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        foregroundColor: AppTheme.textPrimary,
        title: const Text('QRコード'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentPrimary,
          labelColor: AppTheme.accentPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.qr_code),
              text: 'マイQR',
            ),
            Tab(
              icon: Icon(Icons.qr_code_scanner),
              text: 'スキャン',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          QrDisplayTab(),
          QrScannerTab(),
        ],
      ),
    );
  }
}
