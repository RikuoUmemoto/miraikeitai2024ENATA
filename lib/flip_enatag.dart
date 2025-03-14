/*-----------
ENATAGを表示するための関数
-------------*/

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:enata/data_store.dart';
import 'package:enata/back_end/dropbox.dart';
import 'dart:io';
import 'dart:typed_data';

// ENATAGを制作した時用(File)
class CustomFlipCard extends StatefulWidget {
  final String userKey;

  final Color nameTagColor; // DBから取得
  final Color nameTextColor; // DBから取得
  final Color commentTagColor; // DBから取得
  final Color commentTextColor; // DBから取得
  final Uint8List? loadedImage1;

  final double enatagWidth = 255.0;
  final double enatagHeight = 382.5;

  const CustomFlipCard({
    Key? key,
    required this.userKey,
    required this.nameTagColor,
    required this.nameTextColor,
    required this.commentTagColor,
    required this.commentTextColor,
    required this.loadedImage1,
  }) : super(key: key);

  @override
  _CustomFlipCardState createState() => _CustomFlipCardState();
}

class _CustomFlipCardState extends State<CustomFlipCard> {
  late Future<Map<String, dynamic>?> _userDataFuture;
  String _userName = '';
  List<String> _interestTags = [];
  String _userComment = '';

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    Map<String, dynamic>? userData = TAG_LIST[widget.userKey];
    if (userData != null) {
      setState(() {
        _userName = userData['名前'] ?? '';
        _interestTags = List<String>.from(userData['趣味'] ?? []);
        _userComment = userData['一言'] ?? '';
      });
    }
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // ローディング中
        }

        if (snapshot.hasError) {
          return Text('エラーが発生しました'); // エラー時
        }

        return FlipCard(
          front: Container(
            width: widget.enatagWidth,
            height: widget.enatagHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 名前
                Container(
                  width: widget.enatagWidth,
                  height: widget.enatagHeight * 0.12,
                  decoration: BoxDecoration(
                    color: widget.nameTagColor,
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 25,
                        color: widget.nameTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // 画像
                if (widget.loadedImage1 != null)
                  Image.memory(
                    widget.loadedImage1!,
                    width: widget.enatagWidth,
                    height: widget.enatagHeight * 0.40,
                    fit: BoxFit.cover,
                  ),

                // 一言
                Container(
                  width: widget.enatagWidth,
                  height: widget.enatagHeight * 0.13,
                  decoration: BoxDecoration(
                    color: widget.commentTagColor,
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: AutoSizeText(
                      // 文字の大きさを自動調整
                      _userComment,
                      style: TextStyle(
                        fontSize: 30,
                        color: widget.commentTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 2,
                      minFontSize: 9,
                      maxFontSize: 50,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // 趣味
                Container(
                  width: widget.enatagWidth,
                  height: widget.enatagHeight * 0.35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero, // デフォルトの余白を削除
                    itemCount: _interestTags.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: AutoSizeText(
                          _interestTags[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          minFontSize: 9,
                          maxFontSize: 50,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 今スプリントでは放置
          back: Container(
            width: widget.enatagWidth,
            height: widget.enatagHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero, // デフォルトの余白を削除
              itemCount: _interestTags.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    _interestTags[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          speed: 350,
        );
      },
    );
  }
}

// 作成しない時用(Uint8List)
class FriendsFlipCard extends StatefulWidget {
  final String userKey;
  final Uint8List? loadedImage1;
  final double enatagWidth = 300.0;
  final double enatagHeight = 450.0;

  const FriendsFlipCard({
    Key? key,
    required this.userKey,
    this.loadedImage1,
  }) : super(key: key);

  @override
  _FriendsFlipCardState createState() => _FriendsFlipCardState();
}

class _FriendsFlipCardState extends State<FriendsFlipCard> {
  late Future<Map<String, dynamic>?> _userDataFuture;
  String _userName = '';
  List<String> _interestTags = [];
  String _userComment = '';
  Color nameTagColor = Colors.lightBlue;
  Color nameTextColor = Colors.black;
  Color commentTagColor = Colors.lightGreen;
  Color commentTextColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    Map<String, dynamic>? userData = TAG_LIST[widget.userKey];
    if (userData != null) {
      setState(() {
        _userName = userData['名前'] ?? '';
        _interestTags = List<String>.from(userData['趣味'] ?? []);
        _userComment = userData['一言'] ?? '';
        nameTagColor = Color(userData['名前背景カラー']);
        nameTextColor = Color(userData['名前文字カラー']);
        commentTagColor = Color(userData['一言背景カラー']);
        commentTextColor = Color(userData['一言文字カラー']);
      });
    }
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // ローディング中
        }

        if (snapshot.hasError) {
          return Text('エラーが発生しました'); // エラー時
        }

        return FlipCard(
          front: Container(
            width: widget.enatagWidth,
            height: widget.enatagHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 名前
                Container(
                  width: widget.enatagWidth,
                  height: widget.enatagHeight * 0.12,
                  decoration: BoxDecoration(
                    color: nameTagColor,
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: AutoSizeText(
                      // 文字の大きさを自動調整
                      _userName,
                      style: TextStyle(
                        fontSize: 30,
                        color: nameTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 2,
                      minFontSize: 9,
                      maxFontSize: 50,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // 画像
                if (widget.loadedImage1 != null)
                  Image.memory(
                    widget.loadedImage1!,
                    width: widget.enatagWidth,
                    height: widget.enatagHeight * 0.40,
                    fit: BoxFit.cover,
                  ),

                // 一言
                Container(
                  width: widget.enatagWidth,
                  height: widget.enatagHeight * 0.13,
                  decoration: BoxDecoration(
                    color: commentTagColor,
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: AutoSizeText(
                      // 文字の大きさを自動調整
                      _userComment,
                      style: TextStyle(
                        fontSize: 30,
                        color: commentTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 2,
                      minFontSize: 9,
                      maxFontSize: 50,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // 趣味
                Container(
                  width: widget.enatagWidth,
                  height: widget.enatagHeight * 0.35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero, // デフォルトの余白を削除
                    itemCount: _interestTags.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: AutoSizeText(
                          _interestTags[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          minFontSize: 9,
                          maxFontSize: 50,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 今スプリントでは放置
          back: Container(
            width: widget.enatagWidth,
            height: widget.enatagHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero, // デフォルトの余白を削除
              itemCount: _interestTags.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    _interestTags[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          speed: 350,
        );
      },
    );
  }
}

// プレビュー用(File)
class previewFlipCard extends StatefulWidget {
  final String userName;
  final String userComment;
  final List<String> interestTags;
  final Color nameTagColor;
  final Color nameTextColor;
  final Color commentTagColor;
  final Color commentTextColor;
  final File? loadedImage1;

  final double enatagWidth = 300.0;
  final double enatagHeight = 450.0;

  const previewFlipCard({
    Key? key,
    required this.userName,
    required this.userComment,
    required this.interestTags,
    required this.nameTagColor,
    required this.nameTextColor,
    required this.commentTagColor,
    required this.commentTextColor,
    this.loadedImage1,
  }) : super(key: key);

  @override
  _previewFlipCardState createState() => _previewFlipCardState();
}

class _previewFlipCardState extends State<previewFlipCard> {
  @override
  Widget build(BuildContext context) {
    return FlipCard(
      front: Container(
        width: widget.enatagWidth,
        height: widget.enatagHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 名前
            Container(
              width: widget.enatagWidth,
              height: widget.enatagHeight * 0.12,
              decoration: BoxDecoration(
                color: widget.nameTagColor,
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: AutoSizeText(
                  // 文字の大きさを自動調整
                  widget.userName,
                  style: TextStyle(
                    fontSize: 30,
                    color: widget.nameTextColor,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  minFontSize: 9,
                  maxFontSize: 50,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // 画像
            if (widget.loadedImage1 != null)
              Image.file(
                widget.loadedImage1!,
                width: widget.enatagWidth,
                height: widget.enatagHeight * 0.40,
                fit: BoxFit.cover,
              ),

            // 一言
            Container(
              width: widget.enatagWidth,
              height: widget.enatagHeight * 0.13,
              decoration: BoxDecoration(
                color: widget.commentTagColor,
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: AutoSizeText(
                  // 文字の大きさを自動調整
                  widget.userComment,
                  style: TextStyle(
                    fontSize: 30,
                    color: widget.commentTextColor,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  minFontSize: 9,
                  maxFontSize: 50,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // 趣味
            Container(
              width: widget.enatagWidth,
              height: widget.enatagHeight * 0.35,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero, // デフォルトの余白を削除
                itemCount: widget.interestTags.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: AutoSizeText(
                      widget.interestTags[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      minFontSize: 9,
                      maxFontSize: 50,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 今スプリントでは放置
      back: Container(
        width: widget.enatagWidth,
        height: widget.enatagHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero, // デフォルトの余白を削除
          itemCount: widget.interestTags.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                widget.interestTags[index],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
      speed: 350,
    );
  }
}
