/*------------------------------------------------------------------
ホーム画面
MyENATAGの表示、TAG管理画面への遷移、QR交換画面への遷移などを行う画面です。
------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:enata/data_store.dart';
import 'second_exchange/second_exchange.dart';
import 'tag_management/Slide_Tag.dart';

// サインアウト用
import 'account/signout_model.dart';

class home extends StatelessWidget {
  const home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 右上の"Debug"の表示タグを削除
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // アプリ開始時にデータを読み込む
    initDataSet();

    // 位置情報の取得を開始
    initLocation();

    // 1秒後に画面遷移を行う
    Future.delayed(
      Duration(seconds: 1),
      () {
        // 画面遷移 (SlideTagに遷移)
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
              return SlideTag(); // タグ編集画面に遷移
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ロード中画面を表示
    return Scaffold(
      body: Container(),
    );
  }
}
