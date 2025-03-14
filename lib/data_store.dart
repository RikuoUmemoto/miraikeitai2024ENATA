/*-------------------
ローカルにデータを保持するファイル

USER_ID           自分のID（emailを使用）
FRIEND_LIST       友達のIDリスト

TAG_LIST          タグ情報一覧（自分、友達含め全て）

FRIEND_EXCHANGE   最近交換した友達のIDリスト

MY_LOCATION       自分の位置情報
FRIEND_LOCATION   友達の位置情報リスト
-------------------*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tag_management/Tag_Browsing.dart';
import 'back_end/firebase.dart';
import 'dart:typed_data';
import 'dart:collection';
import 'package:flutter/material.dart';

String USER_ID = '';
List<String> FRIEND_LIST = [];

Map<String, Map<String, dynamic>> TAG_LIST = {};


ValueNotifier<LinkedHashSet<String>> FRIEND_EXCHANGE =
    ValueNotifier(LinkedHashSet<String>());
GeoPoint MY_LOCATION = GeoPoint(0.0, 0.0);
Map<String, GeoPoint> FRIEND_LOCATION = {};
List<String> NEARBY_IDS = [];

Map<String, Uint8List> FRIEND_IMAGES = {};

//
// アプリ開始時にデータをセットする関数
//
void initDataSet() async {
  // 自分のIDをセット
  USER_ID = FirebaseAuth.instance.currentUser!.email ?? '';

  // フレンドリストを取得
  FRIEND_LIST = await getFriendList(USER_ID);

  // 自分TAG情報を取得
  TAG_LIST[USER_ID] = await getData(USER_ID) ?? {};

  // 友達のTAG情報を取得
  for (var friendId in FRIEND_LIST) {
    TAG_LIST[friendId] = await getData(friendId) ?? {};
  }

  // 画像のプリロード
  FRIEND_IMAGES = await TagBrowsing.preloadImages();

  // テスト用：一旦友達リストの友達をFRIEND_EXCHANGEへ
  FRIEND_EXCHANGE.value = LinkedHashSet.from(FRIEND_LIST);

}
