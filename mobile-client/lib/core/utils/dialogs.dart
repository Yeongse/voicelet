import 'package:flutter/cupertino.dart';

/// iOS標準の確認ダイアログを表示
///
/// [title] - ダイアログのタイトル（オプション）
/// [message] - 確認メッセージ
/// [destructiveText] - 破壊的アクションのボタンテキスト（赤色で表示）
/// [cancelText] - キャンセルボタンのテキスト
///
/// 戻り値: 破壊的アクションが選択された場合は true、キャンセルの場合は false
Future<bool> showDestructiveConfirmDialog({
  required BuildContext context,
  String? title,
  required String message,
  required String destructiveText,
  String cancelText = 'キャンセル',
}) async {
  final result = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: title != null ? Text(title) : null,
      message: Text(message),
      actions: [
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, true),
          child: Text(destructiveText),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, false),
        child: Text(cancelText),
      ),
    ),
  );
  return result ?? false;
}

/// iOS標準の確認アラートダイアログを表示（中央に表示されるタイプ）
///
/// ActionSheetではなく、画面中央に表示されるアラートダイアログ
Future<bool> showConfirmAlertDialog({
  required BuildContext context,
  required String title,
  String? message,
  required String confirmText,
  String cancelText = 'キャンセル',
  bool isDestructive = false,
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: message != null ? Text(message) : null,
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        CupertinoDialogAction(
          isDestructiveAction: isDestructive,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// iOS標準の選択肢ダイアログを表示
///
/// 複数の選択肢から1つを選ぶ場合に使用
Future<T?> showOptionsDialog<T>({
  required BuildContext context,
  String? title,
  String? message,
  required List<DialogOption<T>> options,
  String cancelText = 'キャンセル',
}) async {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: title != null ? Text(title) : null,
      message: message != null ? Text(message) : null,
      actions: options
          .map(
            (option) => CupertinoActionSheetAction(
              isDestructiveAction: option.isDestructive,
              onPressed: () => Navigator.pop(context, option.value),
              child: Text(option.label),
            ),
          )
          .toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: Text(cancelText),
      ),
    ),
  );
}

/// ダイアログの選択肢
class DialogOption<T> {
  final String label;
  final T value;
  final bool isDestructive;

  const DialogOption({
    required this.label,
    required this.value,
    this.isDestructive = false,
  });
}
