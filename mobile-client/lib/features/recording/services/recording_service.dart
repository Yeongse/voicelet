import 'dart:async';
import 'package:record/record.dart';
import 'storage_service.dart';

/// 録音状態
enum RecordingState {
  idle,
  recording,
  stopped,
  error,
}

/// 権限拒否例外
class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}

/// 録音結果
class RecordingResult {
  final String filePath;
  final String fileName;
  final Duration duration;
  final int fileSize;

  RecordingResult({
    required this.filePath,
    required this.fileName,
    required this.duration,
    required this.fileSize,
  });
}

/// 音声録音の開始・停止・設定を管理するサービス
class RecordingService {
  /// 最大録音時間
  static const Duration maxDuration = Duration(seconds: 30);

  final AudioRecorder _recorder = AudioRecorder();
  final StorageService _storageService;

  /// 現在の録音状態
  final _stateController = StreamController<RecordingState>.broadcast();
  Stream<RecordingState> get stateStream => _stateController.stream;

  /// 音量レベルストリーム（波形表示用）
  final _amplitudeController = StreamController<double>.broadcast();
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// 経過時間ストリーム
  final _durationController = StreamController<Duration>.broadcast();
  Stream<Duration> get durationStream => _durationController.stream;

  RecordingState _currentState = RecordingState.idle;
  String? _currentFilePath;
  String? _currentFileName;
  DateTime? _startTime;
  Timer? _durationTimer;
  Timer? _amplitudeTimer;
  Timer? _autoStopTimer;

  RecordingService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  /// 録音を開始する
  /// throws PermissionDeniedException if microphone access denied
  Future<void> startRecording(String userId) async {
    // 権限確認
    if (!await _recorder.hasPermission()) {
      _updateState(RecordingState.error);
      throw PermissionDeniedException(
        'マイクへのアクセスが許可されていません。設定からマイクへのアクセスを許可してください。',
      );
    }

    // ストレージ容量確認
    final storageInfo = await _storageService.getStorageInfo();
    if (!storageInfo.hasEnoughSpace) {
      _updateState(RecordingState.error);
      throw StorageException(
        'ストレージ容量が不足しています',
        StorageErrorType.insufficientSpace,
      );
    }

    // ファイル名とパスを生成
    _currentFileName = _storageService.generateFileName(userId);
    _currentFilePath = await _storageService.getTempFilePath(_currentFileName!);

    // 録音設定（高品質AAC）
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
      numChannels: 1,
    );

    // 録音開始
    await _recorder.start(config, path: _currentFilePath!);
    _startTime = DateTime.now();
    _updateState(RecordingState.recording);

    // 経過時間の更新を開始
    _startDurationTimer();

    // 音量レベルの更新を開始
    _startAmplitudeTimer();

    // 30秒自動停止タイマーを開始
    _startAutoStopTimer();
  }

  /// 録音を停止し、ファイルパスとファイル名を返す
  Future<RecordingResult> stopRecording() async {
    _stopTimers();

    final path = await _recorder.stop();
    if (path == null || _currentFilePath == null || _currentFileName == null) {
      _updateState(RecordingState.error);
      throw StateError('録音が正常に停止できませんでした');
    }

    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    final fileSize = await _storageService.getFileSize(_currentFilePath!);

    _updateState(RecordingState.stopped);

    return RecordingResult(
      filePath: _currentFilePath!,
      fileName: _currentFileName!,
      duration: duration,
      fileSize: fileSize,
    );
  }

  /// 録音をキャンセルして破棄
  Future<void> cancelRecording() async {
    _stopTimers();

    await _recorder.stop();

    if (_currentFilePath != null &&
        await _storageService.fileExists(_currentFilePath!)) {
      try {
        await _storageService.deleteFile(_currentFilePath!);
      } catch (_) {
        // ファイル削除に失敗しても無視
      }
    }

    _currentFilePath = null;
    _currentFileName = null;
    _startTime = null;
    _updateState(RecordingState.idle);
  }

  /// リソースを解放
  Future<void> dispose() async {
    _stopTimers();
    await _recorder.dispose();
    await _stateController.close();
    await _amplitudeController.close();
    await _durationController.close();
  }

  void _updateState(RecordingState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        _durationController.add(elapsed);
      }
    });
  }

  void _startAmplitudeTimer() {
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
      if (_currentState == RecordingState.recording) {
        try {
          final amplitude = await _recorder.getAmplitude();
          // dBFS値を0.0-1.0の範囲に正規化
          // 通常のdBFS範囲は-60〜0
          final normalized = ((amplitude.current + 60) / 60).clamp(0.0, 1.0);
          _amplitudeController.add(normalized);
        } catch (_) {
          // 振幅取得に失敗しても無視
        }
      }
    });
  }

  void _startAutoStopTimer() {
    _autoStopTimer = Timer(maxDuration, () async {
      if (_currentState == RecordingState.recording) {
        await stopRecording();
      }
    });
  }

  void _stopTimers() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
  }
}
