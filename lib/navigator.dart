/*----------------------
ナビゲーションバーの表示
----------------------*/
import 'package:flutter/material.dart';

import 'tag_exchange/QR_scan.dart';
import 'tag_management/Edit_Tag.dart';
import 'tag_management/Slide_Tag.dart';
import 'tag_management/Tag_Browsing.dart';

class navigator extends StatelessWidget {
  final Color backgroundColor = Colors.black; // 背景色を設定
  final double iconSize = 45.0; // アイコンサイズ
  final Color iconColor = Colors.white; // アイコンの色
  late String nowScreen;

  // コンストラクタで背景色とアイコンサイズを受け取る
  navigator(String nowscreen) {
    nowScreen = nowscreen;
  }

  // 現在の画面を判定してアイコンの色を変える
  Color checkNowScreen(String highlightScreen) {
    final highlightColor = const Color.fromARGB(255, 236, 218, 51); // アイコンの色
    if (highlightScreen == nowScreen) {
      return Color.fromARGB(highlightColor.alpha, highlightColor.red,
          highlightColor.green, highlightColor.blue);
    } else {
      return iconColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.handshake, // アイコンの種類
                size: iconSize,
                color: checkNowScreen(
                    '/TagBrowsing')), // アイコンのサイズと色(色は現在の画面を判定して色を変更します)
            onPressed: () {
              Navigator.pushReplacement(
                // 画面遷移を行う
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 300), // アニメーションの時間
                  transitionsBuilder: // アニメーションの設定
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      // フェードインアニメーション
                      opacity: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return TagBrowsing(); // タグ閲覧画面に遷移
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.home,
                size: iconSize, color: checkNowScreen('/home')),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 300),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return SlideTag(); // ホーム画面に遷移
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person,
                size: iconSize, color: checkNowScreen('/EditTags')),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 300),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return EditTags(); // タグ編集画面に遷移
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.qr_code_2,
                size: iconSize, color: checkNowScreen('/QRscan')),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 300),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return QR_scan(); // QRスキャン画面に遷移
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
