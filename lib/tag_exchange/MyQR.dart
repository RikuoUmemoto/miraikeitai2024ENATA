/*-------------------------------------------
MyQR画面
QRスキャン画面とMyENATAGへの遷移を行う画面です。
-----------------------------------------*/

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QRコード生成用のパッケージ
import 'package:enata/data_store.dart';
import 'QR_scan.dart';

class MyQR extends StatelessWidget {
  //  コンストラクタ
  const MyQR({super.key});

  @override
  Widget build(BuildContext context) {
    //
    // このメソッドはページのレイアウトを構築します
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ここでQRコードの生成
            QrImageView(
              data: USER_ID, // 生成したいQRコードのデータ
              size: 300, // QRコードのサイズ
            ),
            ElevatedButton(
              child: const Text("QRコードスキャン",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                overlayColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QR_scan()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
