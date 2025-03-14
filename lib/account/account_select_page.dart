/*----------------------------------------------
ログイン/新規登録画面のページ
-----------------------------------------------*/

import 'package:flutter/material.dart';
import 'login_model.dart';
import 'signup_model.dart';
import '../home.dart';
import 'create_MyTAG.dart';

class AccountSelect extends StatelessWidget {
  // コンストラクタ
  AccountSelect({super.key});

  final mailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //
    // このメソッドはページのレイアウトを構築します
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: size.width / 2,
                height: size.width / 2,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset('assets/app_icon.png'),
                ),
              ),

              SizedBox(
                height: size.height / 15,
              ),
              Container(
                width: size.width * 0.9,
                child: Text(
                  'メールアドレス',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20),
                ),
              ),

              Container(
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'example@example.com',
                  ),
                  controller: mailController,
                ),
              ),

              SizedBox(
                height: size.height / 90,
              ),
              Container(
                width: size.width * 0.9,
                child: Text(
                  'パスワード',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20),
                ),
              ),

              Container(
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  obscureText: true,
                  controller: passwordController,
                ),
              ),

              SizedBox(
                height: size.height / 15,
              ),
              //
              // ログインボタン
              ElevatedButton(
                onPressed: () async {
                  // ログイン処理
                  bool isSuccess = await LoginModel().signIn(
                      context, mailController.text, passwordController.text);

                  // 成功時はホームへ
                  if (isSuccess) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => home()),
                      (Route<dynamic> route) => false, // 全てのルートを削除
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(size.width * 0.6, 60),
                  side: BorderSide(color: Colors.black),
                ),
                child: Text(
                  'ログイン(ホームへ)',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),

              SizedBox(
                height: size.height / 45,
              ),
              //
              // サインアップボタン
              ElevatedButton(
                onPressed: () async {
                  // サインアップ処理
                  bool isSuccess = await SignUpModel().signUp(
                      context, mailController.text, passwordController.text);

                  // サインアップ成功時は遷移する
                  if (isSuccess) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => CreateMyTAG()),
                      (Route<dynamic> route) => false, // 全てのルートを削除
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(size.width * 0.6, 60),
                  side: BorderSide(color: Colors.black),
                ),
                child: Text(
                  '新規登録',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),

              SizedBox(
                height: size.height / 45,
              ),
              //
              // 開発者用ボタン
              ElevatedButton(
                onPressed: () async {
                  // ログイン処理
                  bool isSuccess = await LoginModel()
                      .signIn(context, "enayama@enayama.com", "password");

                  // 成功時はホームへ
                  if (isSuccess) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => home()),
                      (Route<dynamic> route) => false, // 全てのルートを削除
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(size.width * 0.6, 60),
                  side: BorderSide(color: Colors.black),
                ),
                child: Text(
                  '開発者用',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),

              SizedBox(
                height: size.height / 45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
