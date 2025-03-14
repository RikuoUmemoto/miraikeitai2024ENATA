/*-----------
タグの編集画面
-------------*/

import 'package:enata/back_end/dropbox.dart';
import 'package:flutter/material.dart';
import 'package:enata/back_end/firebase.dart';
import 'package:enata/data_store.dart';
import 'package:enata/flip_enatag.dart';
import 'package:enata/account/insert_photo.dart';
import 'package:enata/account/create_MyTAG.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../navigator.dart';

class EditTags extends StatefulWidget {
  const EditTags({super.key});

  @override
  State<EditTags> createState() => _EditTagsState();
}

class _EditTagsState extends State<EditTags> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  File? photo;

  List<String> selectedHobbies = [];

  String userName = TAG_LIST[USER_ID]!['名前'];

  // 名前・一言の色
  Color nameTagColor = Colors.lightBlue;
  Color nameTextColor = Colors.black;
  Color commentTagColor = Colors.lightGreen;
  Color commentTextColor = Colors.black;

  // 自分の趣味タグ
  List<String> myInterestTags = TAG_LIST[USER_ID]!['趣味'].cast<String>();

  @override
  void initState() {
    super.initState();

    // 初期値を設定
    _nameController.text = TAG_LIST[USER_ID]?['名前'] ?? '';
    _commentController.text = TAG_LIST[USER_ID]?['一言'] ?? '';
    selectedHobbies = List<String>.from(TAG_LIST[USER_ID]?['趣味'] ?? []);
    nameTagColor = Color(TAG_LIST[USER_ID]?['名前背景カラー']);
    nameTextColor = Color(TAG_LIST[USER_ID]?['名前文字カラー']);
    commentTagColor = Color(TAG_LIST[USER_ID]?['一言背景カラー']);
    commentTextColor = Color(TAG_LIST[USER_ID]?['一言文字カラー']);
    _loadPhoto();
    setState(() {});
  }

  // photoに画像をセットする
  Future<void> _loadPhoto() async {
    final photoFile = await _convertUint8ListToFile(FRIEND_IMAGES[USER_ID]);
    setState(() {
      photo = photoFile; // 非同期で取得した写真を設定
    });
  }

  // Uint8ListをFileに変換する
  Future<File?> _convertUint8ListToFile(Uint8List? imageBytes) async {
    if (imageBytes == null) return null;

    try {
      final directory = await getTemporaryDirectory();

      final String fileName =
          'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final filePath = '${directory.path}/$fileName';

      // Uint8ListをFileに書き込む
      File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return file;
    } catch (e) {
      print('Error converting Uint8List to File: $e');
      return null;
    }
  }

  // 背景色に応じて文字色を決定する関数
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

  // 趣味タグを追加する関数
  void addTag(String tag) {
    setState(() {
      if (!myInterestTags.contains(tag)) {
        myInterestTags.add(tag);
      }
    });
  }

  // 趣味タグを削除する関数
  void removeTag(String tag) {
    setState(() {
      myInterestTags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 画像が読み込まれていない場合にローディングインディケーターを表示
    if (photo == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('ENATAG編集'),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        hintText: TAG_LIST[USER_ID]?['名前'] ?? '未設定',
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: '一言コメント',
                      border: OutlineInputBorder(),
                      hintText: TAG_LIST[USER_ID]?['一言'] ?? '未設定',
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
              ]),
              const SizedBox(height: 16),

              // タグ選択
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
                    onSelected: (isSelected) {
                      setState(() {
                        isSelected
                            ? selectedHobbies.add(tag)
                            : selectedHobbies.remove(tag);
                      });
                    },
                    backgroundColor: selectedHobbies.contains(tag)
                        ? Colors.lightBlue.shade100
                        : null,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 画像の選択
              InsertPhoto(
                title: "photo",
                photo: photo,
                onPhotoSelected: (File? selectedPhoto) {
                  setState(() {
                    photo = selectedPhoto;
                  });
                },
              ),

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
                    icon: Icon(Icons.save),
                    label: const Text('保存'),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        fixedSize: Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        )),
                    onPressed: () async {
                      try {
                        Map<String, dynamic> updatedData = {
                          '名前': _nameController.text,
                          '一言': _commentController.text,
                          '趣味': selectedHobbies,
                          '名前背景カラー': nameTagColor.value,
                          '名前文字カラー': nameTextColor.value,
                          '一言背景カラー': commentTagColor.value,
                          '一言文字カラー': commentTextColor.value
                        };

                        // Firestoreにデータを保存
                        await setData(USER_ID, updatedData);

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

                        // ローカルの画像も更新
                        FRIEND_IMAGES[USER_ID] = await photo!.readAsBytes();

                        print('正常に保存されました');

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('保存しました！'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('予期せぬエラーが発生しました'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: navigator('/EditTags'), // ナビゲーションバーの表示
    );
  }
}
