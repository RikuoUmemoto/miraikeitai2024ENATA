/*----------------------------------------
 QRスキャン画面
 QRスキャン、自分のQR表示画面への遷移などを行う画面です。
 ----------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:enata/data_store.dart';
import '../back_end/firebase.dart';
import '../navigator.dart';
import 'MyQR.dart';
import '../tag_management/ENATAG_opponent.dart';

class QR_scan extends StatelessWidget {
  const QR_scan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // QRコードのスキャン
            SizedBox(
              height: 300,
              width: 300,

              // MobileScanner: QRコードをスキャンする
              child: MobileScanner(
                // QRコードを検出したときの処理
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  String qrData = '';

                  for (final barcode in barcodes) {
                    // グローバル変数にQRコードの内容を格納
                    qrData = barcode.rawValue ?? '';
                    // debugPrint: コンソールにスキャンしたQRコードの内容を表示
                    debugPrint('Barcode found! $qrData');
                    Navigator.of(context).pop(); // Close scanner

                    // 読み込んだ友達のIDをDBに保存
                    addFriend(USER_ID, qrData);

                    // QRデータを保持したまま success_exchange へ
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnatagOpponent(qrData: qrData),
                      ),
                    );
                    break;
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            // 自分のQRコードを表示するボタン
            ElevatedButton(
              child: const Text(
                "MYQRを表示",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                  MaterialPageRoute(builder: (context) => const MyQR()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: navigator('/QRscan'), // ナビゲーションバーの表示
    );
  }
}
