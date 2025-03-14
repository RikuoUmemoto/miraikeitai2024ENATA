/*--------------------
サインアウト用関数ファイル
ほとんど何もないですが、ログインやサインアップと形式を揃えるためのファイルです
---------------------*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../function.dart';

class SignOutModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // サインアウト関数
  Future<bool> signOut(BuildContext context) async {
    try {
      _auth.signOut();
    } catch (e) {
      showErrorDialog(context, 'エラー', 'サインアウトに失敗しました。');
      return false;
    }

    return true;
  }
}
