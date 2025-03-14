/*--------------------
諸々の関数用ファイル
---------------------*/

import 'package:flutter/material.dart';
import 'dart:math';

// エラーダイアログを表示する関数
void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

// 背景色に応じて文字色を決定する関数
Color getTextColor(Color backgroundColor) {
  // 背景色に応じた文字色の変更する関数
  return backgroundColor.computeLuminance() < 0.5
      ? Colors.white // 背景が暗い場合
      : Colors.black; // 背景が明るい場合
}

Color getRandomColor() {
  // 背景色をランダムに決定する関数
  Random random = Random();
  return Color.fromARGB(
    255, // 固定の透明度（255は完全不透明）
    random.nextInt(256), // R (0~255)
    random.nextInt(256), // G (0~255)
    random.nextInt(256), // B (0~255)
  );
}
