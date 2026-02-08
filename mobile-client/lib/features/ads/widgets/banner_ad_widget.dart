import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

/// バナー広告ウィジェット
///
/// - 読み込み中は固定高さのプレースホルダーを表示
/// - 読み込み失敗時は非表示（高さ0）
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService.instance.createBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('[BannerAdWidget] Failed to load: ${error.message}');
        ad.dispose();
        if (mounted) {
          setState(() {
            _hasFailed = true;
            _bannerAd = null;
          });
        }
      },
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 失敗時は非表示
    if (_hasFailed) {
      return const SizedBox.shrink();
    }

    // バナー広告の標準サイズ（320x50）
    const bannerHeight = 50.0;

    // 読み込み中はプレースホルダー
    if (!_isLoaded || _bannerAd == null) {
      return Container(
        width: double.infinity,
        height: bannerHeight,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // 広告表示
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
