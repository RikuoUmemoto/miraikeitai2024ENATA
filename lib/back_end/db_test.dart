/*------------------------------------
ファイアベース（データベース）のテスト用ファイル
-------------------------------------*/

import 'package:flutter/material.dart';
import 'package:enata/data_store.dart';
import 'firebase.dart';

class DBTest extends StatefulWidget {
  // コンストラクタ
  const DBTest({super.key});

  @override
  _DBTestState createState() => _DBTestState();
}

class _DBTestState extends State<DBTest> {
  // テキストコントローラーをフィールドとして定義
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _hobbyController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  @override
  void dispose() {
    // 使用が終わったコントローラーを解放
    _keyController.dispose();
    _nameController.dispose();
    _originController.dispose();
    _hobbyController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarウィジェットで画面の上部にバーを表示
      appBar: AppBar(
        // AppBarに表示されるタイトルを設定
        title: const Text('データベーステスト用ページ'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // テキストボックス（キー入力）
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'キー',
                hintText: 'キーを入力してください',
                prefixIcon: Icon(Icons.key),
              ),
            ),

            const SizedBox(height: 30), // ボタン間の余白を設定

            // テキストボックス（名前）
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名前',
              ),
            ),

            // テキストボックス（出身地）
            TextField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: '出身地',
              ),
            ),

            // テキストボックス（趣味）
            TextField(
              controller: _hobbyController,
              decoration: const InputDecoration(
                labelText: '趣味',
              ),
            ),

            // ここは画像を入力できる様に
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: '画像',
              ),
            ),
            const SizedBox(height: 20), // ボタン間の余白を設定

            // 情報登録ボタン
            ElevatedButton(
              onPressed: () {
                // データを登録する関数を呼び出す
                setData(
                  _keyController.text,
                  {
                    '名前': _nameController.text,
                    '出身地': _originController.text,
                    '趣味': _hobbyController.text,
                    '画像': _imageController.text,
                  },
                );
              },
              child: const Text('情報登録'),
            ),

            // 情報取得ボタン
            ElevatedButton(
              onPressed: () {
                // テキストフィールドにデータをセットする
                setState(
                  () {
                    _nameController.text = TAG_LIST[USER_ID]!['名前'] ?? 'null';
                    _originController.text =
                        TAG_LIST[USER_ID]!['出身地'] ?? 'null';
                    _hobbyController.text =
                        TAG_LIST[USER_ID]!['趣味'][0] ?? 'null';
                    _imageController.text = TAG_LIST[USER_ID]!['画像'] ?? 'null';
                  },
                );
              },
              child: const Text('情報取得'),
            ),

            const SizedBox(height: 20), // ボタン間の余白を設定

            // テキストフィールドリセットボタン
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _keyController.text = '';
                  _nameController.text = '';
                  _originController.text = '';
                  _hobbyController.text = '';
                  _imageController.text = '';
                });
              },
              child: const Text('テキストフィールドリセット（デバッグ用）'),
            ),
          ],
        ),
      ),
    );
  }
}
