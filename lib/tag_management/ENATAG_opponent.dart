/*----------------------------------------------------------
 相手のENATAGを表示する画面
 MyENATAGへの遷移、相手の趣味TAGチェックなどを行う画面です。
 --------------------------------------------------------*/
import 'package:enata/back_end/firebase.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:enata/data_store.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../home.dart';

class EnatagOpponent extends StatefulWidget {
  // QRのデータをsuccess_exchangeから受け取る
  final String qrData;
  const EnatagOpponent({Key? key, required this.qrData}) : super(key: key);

  @override
  State<EnatagOpponent> createState() => _EnatagOpponent();
}

class _EnatagOpponent extends State<EnatagOpponent>
    with TickerProviderStateMixin {
  String qrName = ""; //　サーバーから名前のテキストデータを受け取る変数
  List<String> qrHobby = []; //　サーバーから趣味のテキストデータを受け取る変数
  List<String> matchHobby = []; //一致している趣味だけがあるリスト
  final Size size = const Size(200, 75); //ボックスの大きさ（横：縦）
  // サーバーからデータを受け取る
  Future<void> fetchUserData() async {
    try {
      Map<String, dynamic>? userData = await getData(widget.qrData);

      if (userData != null) {
        setState(
          () {
            qrName = "${userData['名前'] ?? ''}  ";

            qrHobby = List<String>.from(userData['趣味'] ?? []);
            print(qrHobby);
          },
        );
      } else {
        print("データが見つかりません");
      }
    } catch (e) {
      print('データの取得に失敗しました : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

// 一致している趣味だけがあるlistを作る
  void matchCheckHobby() {
    List<String> myHobby =
        List<String>.from(TAG_LIST[USER_ID]?["趣味"]); //自分の趣味を取得
    qrHobby.forEach(
      (hobby) {
        if (myHobby.contains(hobby)) {
          matchHobby.add(hobby);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    matchCheckHobby(); //一致している趣味を取得する
    // このメソッドはページのレイアウトを構築します
    return Scaffold(
      backgroundColor: Colors.white, //全体の背景色設定

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20), // 上部のスペースを確保
            //「はじめまして＋名前さん」の設定
            Container(
              //枠についての設定
              constraints: const BoxConstraints(
                maxWidth: 350, // 横幅を広げる
              ),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.836), // 塗りつぶしの色
                borderRadius: BorderRadius.circular(12), // 角を丸くする
                border: Border.all(
                    color: Colors.black, //枠の色
                    width: 2 //枠の太さ
                    ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "はじめまして\n${qrName}さん！", // 挨拶と名前
                textAlign: TextAlign.center, // テキストを中央揃え
                style: GoogleFonts.zenMaruGothic(
                  fontSize: 30, //文字サイズ
                  fontWeight: FontWeight.bold,
                  color: Colors.black, //文字の色
                ),
              ),
            ),

            const SizedBox(height: 20), // 間のスペース

            // QRコードの内容を表示
            // 「共通している趣味タグ」のレイアウト設定
            Container(
              //枠に関する設定
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // 角を丸くする
                color: const Color.fromARGB(246, 255, 209, 59), // 塗りつぶしの色
                border: Border.all(color: Colors.black, width: 1),
              ),
              padding: const EdgeInsets.all(16.0),
              // 表示する文字の設定
              child: Text(
                "共通する趣味タグ",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20), // 間のスペース

            // 趣味タグのレイアウト設定
            Expanded(
                child: GridView.count(
              //リストを用いて2列で表示する各種設定
              padding: const EdgeInsets.symmetric(horizontal: 30), // 左右に余白を追加
              crossAxisCount: 2, // 2列で表示
              crossAxisSpacing: 16, // 列間のスペース
              mainAxisSpacing: 16, // 行間のスペース
              childAspectRatio: 2.6, // ボックスの縦横比(縦横3:1)
              children: matchHobby.map(
                (hobby) {
                  return Container(
                    //趣味タグのレイアウトとスタイル設定
                    decoration: BoxDecoration(
                      color: const Color(0xE940A9FF), // 塗りつぶしの色
                      borderRadius: BorderRadius.circular(12), // 角を丸くする
                      border: Border.all(
                          color: Colors.black, //枠線の色
                          width: 2 //枠線の太さ
                          ),
                    ),
                    alignment: Alignment.center, // テキストを中央に配置
                    child: AutoSizeText(
                      hobby, // 趣味の名前を表示
                      style: GoogleFonts.lato(
                        fontSize: 30, //文字サイズ
                        fontWeight: FontWeight.w900, // 太字をさらに強調
                        color: Colors.black, //文字の色
                      ),
                      maxLines: 1, //1行に収まるようにフォントサイズを変更する
                    ),
                  );
                },
              ).toList(),
            )),
            const SizedBox(height: 20), // 間のスペース

            ElevatedButton.icon(
              icon: Icon(Icons.home),
              label: const Text('ホームに戻る'),
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  fixedSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  )),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => home()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
