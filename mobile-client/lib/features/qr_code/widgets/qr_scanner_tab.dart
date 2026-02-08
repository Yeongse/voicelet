import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../utils/qr_code_utils.dart';

/// QRコードをスキャンするタブ
class QrScannerTab extends ConsumerStatefulWidget {
  const QrScannerTab({super.key});

  @override
  ConsumerState<QrScannerTab> createState() => _QrScannerTabState();
}

class _QrScannerTabState extends ConsumerState<QrScannerTab> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // スキャナーを一時停止
    await _controller?.stop();

    // QRコードを検証
    final result = QrCodeUtils.parseQrCode(rawValue);

    if (!result.isValid) {
      _showError('このQRコードは読み取れません');
      return;
    }

    final userId = result.userId!;
    final currentUserId = ref.read(currentUserIdProvider);

    // ネットワーク状態を確認
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none);

    if (isOffline) {
      _showError('ネットワーク接続を確認してください');
      return;
    }

    if (!mounted) return;

    // QRコード画面を先に閉じてから遷移
    context.pop();

    // 自分自身のQRコードかチェック
    if (currentUserId != null && userId == currentUserId) {
      // 自分のプロフィールに遷移
      context.push('/profile');
    } else {
      // 他のユーザーのプロフィールに遷移
      context.push('/users/$userId');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isProcessing = false;
    });

    // 2秒後にスキャナーを再開
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
        _controller?.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // カメラビュー
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error) => _buildPermissionError(error),
        ),
        // スキャンオーバーレイ
        _buildScanOverlay(),
        // エラーメッセージ
        if (_errorMessage != null) _buildErrorBanner(),
        // 処理中インジケーター
        if (_isProcessing && _errorMessage == null) _buildProcessingIndicator(),
      ],
    );
  }

  Widget _buildPermissionError(MobileScannerException error) {
    String message;
    IconData icon;

    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      message = 'カメラへのアクセスを許可してください';
      icon = Icons.camera_alt_outlined;
    } else {
      message = 'カメラを起動できませんでした';
      icon = Icons.error_outline;
    }

    return Container(
      color: AppTheme.bgPrimary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (error.errorCode == MobileScannerErrorCode.permissionDenied)
              TextButton(
                onPressed: () {
                  // 設定画面を開くよう促す
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('設定アプリからカメラの権限を許可してください'),
                    ),
                  );
                },
                child: Text(
                  '設定を開く',
                  style: TextStyle(color: AppTheme.accentPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return IgnorePointer(
      child: Stack(
        children: [
          // 暗いオーバーレイ
          Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          // 中央の透明な領域
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: AppTheme.accentPrimary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
          ),
          // コーナーマーカー
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: _CornerPainter(color: AppTheme.accentPrimary),
              ),
            ),
          ),
          // 下部テキスト
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'QRコードを枠内に合わせてください',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.error.withValues(alpha: 0.9),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.accentPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                '処理中...',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// コーナーマーカーを描画するペインター
class _CornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  _CornerPainter({
    required this.color,
    this.cornerLength = 30,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 左上
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, cornerLength),
      paint,
    );

    // 右上
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // 左下
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );

    // 右下
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
