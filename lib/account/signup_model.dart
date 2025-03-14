/*--------------------
サインアップ用関数ファイル
---------------------*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enata/data_store.dart';
import '../function.dart';

class SignUpModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // サインアップ関数
  Future<bool> signUp(
      BuildContext context, String email, String password) async {
    if (email.isEmpty) {
      showErrorDialog(context, '入力エラー', 'メールアドレスを入力してください');
      return false;
    }

    if (password.isEmpty) {
      showErrorDialog(context, '入力エラー', 'パスワードを入力してください');
      return false;
    }

    // Firebase Authenticationにユーザを登録
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      USER_ID = FirebaseAuth.instance.currentUser!.email ?? '';
    } on FirebaseAuthException catch (e) {
      // エラー処理
      switch (e.code) {
        case 'invalid-email':
          showErrorDialog(context, '入力エラー', 'メールアドレスの形式が間違っています。');
          break;

        case 'email-already-in-use':
          showErrorDialog(context, '入力エラー', 'そのメールアドレスはすでに登録されています。');
          break;

        default:
          showErrorDialog(context, '予期せぬエラー', 'エラーが発生しました: ${e.message}');
      }

      return false;
    }

    return true;
  }
}
