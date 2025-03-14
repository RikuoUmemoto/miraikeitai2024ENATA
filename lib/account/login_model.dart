/*--------------------
ログイン用関数ファイル
---------------------*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enata/data_store.dart';
import '../function.dart';

class LoginModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ログイン関数
  Future<bool> signIn(
      BuildContext context, String email, String password) async {
    if (email.isEmpty) {
      showErrorDialog(context, '入力エラー', 'メールアドレスを入力してください');
      return false;
    }

    if (password.isEmpty) {
      showErrorDialog(context, '入力エラー', 'パスワードを入力してください');
      return false;
    }

    // ログイン処理
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      USER_ID = FirebaseAuth.instance.currentUser!.email ?? '';
    } on FirebaseAuthException catch (e) {
      // エラー処理
      switch (e.code) {
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-credential': // メールアドレスかパスワードが間違っている場合、このエラーコードになるため。（原因は不明）
          showErrorDialog(context, '入力エラー', 'メールアドレスかパスワードが間違っています。');
          break;

        case 'invalid-email':
          showErrorDialog(context, '入力エラー', 'メールアドレスの形式が間違っています。');
          break;

        default:
          showErrorDialog(context, '予期せぬエラー', 'エラーが発生しました: ${e.message}');
      }

      return false;
    }

    return true;
  }
}
