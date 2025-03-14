/*----------
友達リスト画面
-----------*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:enata/data_store.dart';
import 'package:enata/flip_enatag.dart';

import '../navigator.dart';
import '../function.dart';
import 'package:enata/back_end/dropbox.dart';
import 'dart:typed_data';

class TagBrowsing extends StatefulWidget {
  const TagBrowsing({super.key});

  @override
  State<TagBrowsing> createState() => _TagBrowsingState();

  // Dropboxからすべての画像をロード
  static Future<Map<String, Uint8List>> preloadImages() async {
    final dropBoxHandler = ProfileImageHandler();
    Map<String, Uint8List> images = {};

    List<Future<void>> tasks = [];
    for (var entry in TAG_LIST.entries) {
      tasks.add(
        dropBoxHandler.getPathFromFirestore(entry.key).then((image) {
          if (image != null) {
            images[entry.key] = image;
          }
        }).catchError((e) {
          print('Error loading image for ${entry.key}: $e');
        }),
      );
    }
    await Future.wait(tasks);
    return images; // プリロードした画像を返す
  }
}

class _TagBrowsingState extends State<TagBrowsing> {
  // 友達リストの全ての名前
  List<String> AllFriendTag = TAG_LIST.entries
      .where((entry) => entry.key != USER_ID) // 自分のTAGは除外
      .map((entry) => entry.value['名前'] as String)
      .toList();

  // 表示用の名前リスト
  List<String> displayTags = [];
  bool isLoading = true; //　ロード中の状態管理

  @override
  void initState() {
    super.initState();
    displayTags = AllFriendTag;
    _loadPreloadedImages();
  }

  Future<void> _loadPreloadedImages() async {
    setState(() {
      isLoading = false; // プリロード済み画像が利用可能であればローディング終了
    });
  }

  void _sortTags(String option) {
    setState(
      () {
        switch (option) {
          case '会った日（昇順）':
            displayTags.sort(); // 今回は仮で名前の昇順でソート（ただし、漢字のソートはできていない）
            break;
          case '会った日（降順）':
            displayTags.sort(
                (a, b) => b.compareTo(a)); // 今回は仮で名前の降順でソート（ただし、漢字のソートはできていない）
            break;
          case '会った回数（昇順）':
            // ここに回数での昇順ソートを書く
            break;
          case '会った回数（降順）':
            // ここに回数での降順ソートを書く
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TAG閲覧'),
        ),
        body: const Center(
          child: CircularProgressIndicator(), // 全体のローディング表示
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort, size: 40),
                    onSelected: _sortTags, // 選択されたオプションに応じた処理を実行
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: '会った日（昇順）',
                        child: Text('会った日（昇順）'),
                      ),
                      const PopupMenuItem(
                        value: '会った日（降順）',
                        child: Text('会った日（降順）'),
                      ),
                      const PopupMenuItem(
                        value: '会った回数（昇順）',
                        child: Text('会った回数（昇順）'),
                      ),
                      const PopupMenuItem(
                        value: '会った回数（降順）',
                        child: Text('会った回数（降順）'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '検索...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        // 検索機能の呼び出し
                        search(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: displayTags.length,
                  itemBuilder: (context, index) {
                    final backgroundColor =
                        getRandomColor(); // 名前の背景色をいったんランダムに決定
                    final friendName = displayTags[index];
                    final friendId = findKeyByName(friendName);
                    final friendImage = FRIEND_IMAGES[friendId]; // プリロード済み画像を参照
                    return Card(
                      color: backgroundColor, // 背景色呼び出し
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            displayTags[index],
                            style: GoogleFonts.delaGothicOne(
                              fontSize: 40,
                              color: getTextColor(
                                  backgroundColor), // 文字色を背景色に応じて決定
                            ),
                          ),
                        ),
                        onTap: () async {
                          // タグをタップした時の処理を記述
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                // サイズを明示的に指定
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: FriendsFlipCard(
                                    userKey: friendId,
                                    loadedImage1: friendImage,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: navigator('/TagBrowsing'), // ナビゲーションバーの表示
    );
  }

  void search(String str) {
    setState(
      () {
        if (str.isEmpty) {
          // 検索文字列が空の場合は全てのタグを表示
          displayTags = List.from(AllFriendTag);
        } else {
          // 検索文字列を含むタグのみをフィルタリング
          displayTags = AllFriendTag.where((tag) => tag.contains(str)).toList();
        }
      },
    );
  }

  // 名前から友達のIDを取得する
  String findKeyByName(String name) {
    return TAG_LIST.entries
        .firstWhere(
          (entry) => entry.value['名前'] == name,
        )
        .key; // 該当するキーを取得
  }
}
