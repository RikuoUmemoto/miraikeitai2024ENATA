/*------------- 
MyTAG作成画面
ユーザーのMyENATAGの新規作成のファイルです。編集画面ではありません。
設定内容:名前-一言コメント-趣味-任意の写真
--------------*/

import 'package:flutter/material.dart';
import 'package:enata/account/insert_photo.dart';
import '../back_end/firebase.dart';
import '../home.dart';
import 'package:enata/flip_enatag.dart';
import 'dart:io';
import 'package:enata/data_store.dart';
import 'package:enata/back_end/dropbox.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// 趣味タグのリスト
List<String> allInterestTags = [
  'TRPG',
  'Web小説',
  'アドベンチャー',
  '石磨き',
  '映画鑑賞',
  'エゴサ',
  'エナジードリンク',
  'エミュレータ',
  '大食い',
  'お菓子作り',
  'お酒',
  'おしゃれ',
  'オレンジジュース',
  '温泉巡り',
  'カードゲーム',
  '絵画鑑賞',
  '貝殻',
  'ガチャガチャ',
  'カヌー',
  'カフェ',
  'カラオケ',
  'カリンバ',
  '韓国グルメ',
  '機械いじり',
  'ギター',
  '金属コレクター',
  '筋トレ',
  'クラシック',
  '契約更改',
  'ゲーム',
  '元素表',
  '高級時計コレクター',
  'コーラ',
  'コスプレ',
  'コレクター',
  'サッカー',
  '散歩',
  '写真撮影',
  'ジンジャーエール',
  '水泳',
  '水球',
  'スカイダイビング',
  'スキー',
  'スケート',
  'スポーツ観戦',
  '聖地巡礼',
  '声優',
  '掃除',
  'ソフトボール',
  'ダーツ',
  'ダイエット',
  'タイピング',
  'ダイラタンシー',
  '卓球',
  'ダンス',
  'ツーリング',
  '釣り',
  '出稼ぎ',
  'デザイナー',
  'テニス',
  'テレビゲーム',
  'ドラマ',
  '謎解き',
  'ニラ栽培',
  '人間観察',
  'バードウォッチング',
  'バスケ',
  'パズル',
  'バドミントン',
  'バレーボール',
  'バロック',
  'バンジージャンプ',
  'ハンドボール',
  'ハンドメイド',
  '美術',
  '美容',
  'ファッション',
  'フィーエルヤッペン',
  'プログラマー',
  '宝石',
  'ボウリング',
  'ボーカロイド',
  'ボードゲーム',
  'ボーリング',
  'マイク',
  '土産',
  '野球',
  'ヨーヨー',
  '旅行',
  'ロボットアニメ',
];

class CreateMyTAG extends StatefulWidget {
  const CreateMyTAG({super.key});

  @override
  _CreateMyTAGState createState() => _CreateMyTAGState();
}

class _CreateMyTAGState extends State<CreateMyTAG> {
  // テキストコントローラーをフィールドとして定義
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  File? photo;

  // 名前・一言の色
  Color nameTagColor = Colors.lightBlue;
  Color nameTextColor = Colors.black;
  Color commentTagColor = Colors.lightGreen;
  Color commentTextColor = Colors.black;

  // 選択された趣味タグを保持するリスト
  List<String> selectedHobbies = [];

  Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() < 0.5
        ? Colors.white // 背景が暗い場合
        : Colors.black; // 背景が明るい場合
  }

  // カラーピッカーを表示
  void _showColorPicker(
      {required Color initialColor,
      required void Function(Color) onColorSelected}) {
    Color selectedColor = initialColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('色を選択'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  availableColors: [
                    Colors.red,
                    Colors.pink,
                    Colors.purple,
                    Colors.deepPurple,
                    Colors.indigo,
                    Colors.blue,
                    Colors.lightBlue,
                    Colors.cyan,
                    Colors.teal,
                    Colors.green,
                    Colors.lightGreen,
                    Colors.lime,
                    Colors.yellow,
                    Colors.amber,
                    Colors.orange,
                    Colors.deepOrange,
                  ],
                  layoutBuilder: (BuildContext context, List<Color> colors,
                      ValueChanged<Color> onColorSelected) {
                    return Wrap(
                      children: colors
                          .map((Color color) => GestureDetector(
                                onTap: () {
                                  // 色をタップした瞬間にチェックマークを移動
                                  setState(() {
                                    selectedColor = color;
                                  });
                                  onColorSelected(color);
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  margin: EdgeInsets.all(5),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: selectedColor == color
                                        ? Border.all(
                                            color: Colors.white,
                                            width: 4,
                                          )
                                        : null,
                                    boxShadow: selectedColor == color
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.6),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: selectedColor == color
                                      ? Icon(
                                          Icons.check,
                                          color: useWhiteForeground(color)
                                              ? Colors.white
                                              : Colors.black,
                                        )
                                      : null,
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('キャンセル'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('選択'),
                  onPressed: () {
                    onColorSelected(selectedColor);
                    setState(() {
                      nameTextColor = getTextColor(nameTagColor);
                      commentTextColor = getTextColor(commentTagColor);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // タグを追加する関数
  void addTag(String tag) {
    setState(() {
      if (!selectedHobbies.contains(tag)) {
        selectedHobbies.add(tag);
      }
    });
  }

  // タグを削除する関数
  void removeTag(String tag) {
    setState(() {
      selectedHobbies.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('MyENATAG作成画面'),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 60),
              // 名前の入力
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '名前',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.color_lens,
                      color: nameTagColor,
                    ),
                    onPressed: () {
                      _showColorPicker(
                          initialColor: nameTagColor,
                          onColorSelected: (Color selectedColor) {
                            setState(() {
                              nameTagColor = selectedColor;
                            });
                          });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // コメントの入力
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: '一言コメント',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.color_lens,
                      color: commentTagColor,
                    ),
                    onPressed: () {
                      _showColorPicker(
                          initialColor: commentTagColor,
                          onColorSelected: (Color selectedColor) {
                            setState(() {
                              commentTagColor = selectedColor;
                            });
                          });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 趣味タグ選択
              const Text(
                '趣味タグを選択',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: allInterestTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: selectedHobbies.contains(tag),
                    onSelected: (bool selected) {
                      if (selected) {
                        addTag(tag);
                      } else {
                        removeTag(tag);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 写真挿入
              InsertPhoto(
                title: "photo",
                photo: photo,
                onPhotoSelected: (File? selectedPhoto) {
                  setState(() {
                    photo = selectedPhoto;
                  });
                },
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // プレビューボタン
                  ElevatedButton.icon(
                    icon: Icon(Icons.search),
                    label: const Text('プレビュー'),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        fixedSize: Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        )),
                    onPressed: () {
                      if (photo == null) {
                        print("写真が選択されていません");
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: previewFlipCard(
                                userName: _nameController.text,
                                userComment: _commentController.text,
                                interestTags: selectedHobbies,
                                nameTagColor: nameTagColor,
                                nameTextColor: nameTextColor,
                                commentTagColor: commentTagColor,
                                commentTextColor: commentTextColor,
                                loadedImage1: photo,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 16), // ボタン間のスペース

                  // 作成ボタン
                  ElevatedButton.icon(
                    icon: Icon(Icons.create),
                    label: const Text('作成'),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        fixedSize: Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        )),
                    onPressed: () async {
                      if (_nameController.text.isEmpty || photo == null) {
                        print('名前または写真が未入力です');
                        return;
                      }

                      final data = {
                        '名前': _nameController.text,
                        '一言': _commentController.text,
                        '趣味': selectedHobbies,
                        '名前背景カラー': nameTagColor.value,
                        '名前文字カラー': nameTextColor.value,
                        '一言背景カラー': commentTagColor.value,
                        '一言文字カラー': commentTextColor.value
                      };

                      try {
                        // データをFirestoreに保存
                        await createAccount(data);
                        // Dropboxに写真をアップロード
                        final dropboxHandler = ProfileImageHandler();
                        final fileName =
                            'user_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
                        final filePathToDropbox =
                            await dropboxHandler.uploadToDropbox(
                          photo!,
                          fileName,
                        );

                        // FirestoreにDropboxのファイルパスを保存
                        await dropboxHandler.saveImagePathToFirestore(
                            USER_ID, filePathToDropbox);

                        print('正常に保存されました');

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => home()),
                          (route) => false,
                        );
                      } catch (e) {
                        print('データの保存に失敗しました: $e');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
