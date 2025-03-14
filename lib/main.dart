/*----------------------------------
メイン画面
アプリ起動時に最初に実行されるファイルです。
-----------------------------------*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:enata/back_end/dropbox.dart';
import 'home.dart';
import 'account/account_select_page.dart';

// firebase用
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 通知機能用
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  //データベースの初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 通知機能の初期化
  FlutterLocalNotificationsPlugin() // インスタンス生成。これに対して「..」から始まるメソッドを呼んでいく
    ..resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>() // androidプラットフォームの機能にアクセス
        ?.requestNotificationsPermission() // 通知許可をユーザに尋ねる部分

    // android, ios 通知の初期設定
    ..initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

  // DropBoxアクセストークン初期化
  ProfileImageHandler profileImageHandler = ProfileImageHandler();
  // ↓ ダミー値
  profileImageHandler.saveAccessToken('your_access_token'); // ← ダミー
  profileImageHandler.saveRefreshToken('your_refresh_token'); // ← ダミー
  await profileImageHandler.initializeTokenManager(); //アクセストークン管理を初期化

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // このウィジェットはアプリケーションのルートです。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENATA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // 最初に表示されるスプラッシュ画面
    );
  }
}

// スプラッシュ画面
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  Future<void> _checkUserLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    await Future.delayed(const Duration(seconds: 2)); // 2秒の遅延（スプラッシュ画面の表示）

    if (user != null) {
      // ログイン済みならホーム画面へ遷移
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => home()),
      );
    } else {
      // 未ログインならアカウント選択画面へ遷移
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AccountSelect()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // スプラッシュ画面のUI
    return Scaffold(
      backgroundColor: Colors.black, // 背景を黒に設定
      body: Center(
        child: Image.asset(
          'assets/app_icon.png', // ロゴのパスを指定
          width: 300,
        ),
      ),
    );
  }
}
