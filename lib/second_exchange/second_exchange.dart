/*--------------------
2回目の交換に関する関数
----------------------*/
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enata/data_store.dart';
import 'package:location/location.dart';

import 'request_location.dart';
import 'search_friends.dart';

void initLocation() async {
  // 位置情報取得のリクエスト
  await RequestLocationPermission.request(Location());
  try {
    // 自分の位置情報を30秒毎に取得して近くの友達を検索
    myLocationUpdates();

    // 60秒ごとに位置情報をDB更新
    _startLocationTracking();
  } catch (e) {
    print('位置情報の取得が許可されませんでした。 : $e');
  }
}

// 30に1回自分の位置情報を取得する
// serch_friendを30秒に1回呼び出して近くの友達を検索する
void myLocationUpdates() {
  // 位置情報の取得と更新を30秒ごとに繰り返す
  Timer.periodic(
    Duration(seconds: 30),
    (timer) async {
      try {
        final location = Location();
        LocationData updatedLocation = await location.getLocation();

        if (updatedLocation.latitude != null &&
            updatedLocation.longitude != null) {
          MY_LOCATION =
              GeoPoint(updatedLocation.latitude!, updatedLocation.longitude!);
          print("位置情報の取得に成功しました:");
        }

        //近くの友達を検索
        findNearbyFriends();
      } catch (e) {
        print("位置情報の取得に失敗しました: $e");
      }
    },
  );
}

// 自分の位置情報をDBに登録＆友達の位置情報を取得(180秒毎)
void _startLocationTracking() {
  Timer.periodic(
    Duration(seconds: 180),
    (timer) async {
      // 位置情報をFirestoreに保存
      await saveLocationToDB();
      await saveFriendsLocationToDB();
    },
  );
}

// ユーザの位置情報をFirestoreに保存
Future<void> saveLocationToDB() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    // 'users' コレクションのログイン中のユーザーのドキュメントに位置情報を保存
    await firestore.collection('users').doc(USER_ID).set(
      {
        '位置情報': MY_LOCATION,
        '位置情報更新日時': FieldValue.serverTimestamp(), // タイムスタンプ
      },
      SetOptions(merge: true), // 既存のデータにマージするオプションを追加
    );
  } catch (e) {
    print('firestoreへの保存に失敗しました。: $e');
  }
}

// 友達の位置情報をFirestoreから取得してFREND_LOCATIONに保存
// 合わせてタグ情報も更新します
Future<void> saveFriendsLocationToDB() async {
  for (String friendId in FRIEND_LIST) {
    try {
      // Firestoreから友達の位置情報を取得
      DocumentSnapshot friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();

      if (friendDoc.exists && friendDoc.data() != null) {
        GeoPoint friendLocation = friendDoc['位置情報'] ?? GeoPoint(0.0, 0.0);
        FRIEND_LOCATION[friendId] = friendLocation;

        // 同時にタグも更新する
        TAG_LIST[friendId] = friendDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("友達の位置情報の取得に失敗しました (ID: $friendId): $e");
    }
  }
}
