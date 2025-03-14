/*-------------------------------------------
ホーム画面
2回目以降に会った人のENATAGを表示する画面です。
-------------------------------------------*/
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart'; // ENATAGをスライドできます
import 'package:enata/data_store.dart';
import 'package:enata/flip_enatag.dart';
import 'dart:collection';
import '../navigator.dart';

//サインアウト
import '../account/signout_model.dart';
import '../account/account_select_page.dart';

class SlideTag extends StatefulWidget {
  const SlideTag({super.key});

  @override
  _SlideTagState createState() => _SlideTagState();
}

class _SlideTagState extends State<SlideTag> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ValueListenableBuilder<LinkedHashSet<String>>(
          valueListenable: FRIEND_EXCHANGE,
          builder: (context, friendExchange, child) {
            // FRIEND_EXCHANGEを逆順に並べ替え
            final reversedList = friendExchange.toList().reversed.toList();

            return Stack(children: [
              Container(
                decoration: BoxDecoration(
                  // 背景をグラデーションにする(現在は白)
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      // 異なる色のグラデーション
                      colors: [Colors.white, Colors.white]),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 中央固定
                    children: [
                      // テキスト表示
                      Text(
                        reversedList.isNotEmpty
                            ? ''
                            : '更新されたENATAGはありません', // 更新されたENATAGがなくなった時のテキストの表示
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      CarouselSlider.builder(
                        // スライドができるようにする
                        options: CarouselOptions(
                          height: 450.0,
                          initialPage: -1,
                          viewportFraction: 1.2,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.vertical,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            setState(() {
                              activeIndex = index; // 現在のインデックスを更新
                            });
                          },
                        ),
                        itemCount: reversedList.length,
                        itemBuilder: (context, index, realIndex) {
                          if (reversedList.isEmpty ||
                              index >= reversedList.length) {
                            return const SizedBox.shrink(); // 空のウィジェットを返す
                          }

                          // 正常な場合
                          return buildCard(
                              reversedList.elementAt(index)); // 正しい画像を表示
                        },
                      ),
                      SizedBox(height: 20),
                      buildIndicator(), // インジケーターを画像の横に表示
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.9, 1),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.black),
                  ),
                  onPressed: () {
                    setState(
                      () {
                        FRIEND_EXCHANGE.value.clear();
                      },
                    );
                  },
                  child: Text('消去'),
                ),
              ),
              // サインアウトボタン
              Positioned(
                top: MediaQuery.of(context).padding.top,
                right: 16.0,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 背景色
                    foregroundColor: Colors.black, // 文字色

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 丸みのある角
                      side: BorderSide(color: Colors.black), // ボーダーの色
                    ),
                  ),
                  icon: Icon(Icons.logout, color: Colors.black), // アイコン
                  label: Text(
                    'サインアウト', // ボタンラベル
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold),
                  ),
                  // 押した時の処理
                  onPressed: () async {
                    // サインアウト処理
                    bool isSuccess = await SignOutModel().signOut(context);

                    // サインアウト成功時にログイン画面に遷移
                    if (isSuccess) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountSelect()),
                        (Route<dynamic> route) => false, // 全てのルートを削除
                      );
                    }
                  },
                ),
              ),
            ]);
          },
        ),
        bottomNavigationBar: navigator('/home'), // ナビゲーションバーの表示
      );

  // ENATAG・インジケーターを表示するウィジェット
  Widget buildCard(String userKey) => Row(
        mainAxisAlignment: MainAxisAlignment.center, // 中央固定
        children: [
          // ENATAGを表示
          Container(
              child: FRIEND_EXCHANGE.value.isNotEmpty // 更新されたENATAGがないときには実行しない
                  ? FriendsFlipCard(
                      // ENATAGを表示する
                      userKey: userKey,
                      loadedImage1: FRIEND_IMAGES[userKey], // Tagholder[0]],
                    )
                  : Text('現在ENATAGはありません')),
        ],
      );

  Widget buildIndicator() => SizedBox(); // 必要ないので空のウィジェットに
}
