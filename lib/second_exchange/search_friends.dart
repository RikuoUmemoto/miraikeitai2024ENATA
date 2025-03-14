/*---------------
近くの友達探索クラス
----------------*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enata/data_store.dart';
import 'package:geolocator/geolocator.dart';
import '../back_end/notification.dart';
import 'dart:collection';

// 近くにいる友達を検索する関数
void findNearbyFriends({double range = 10.0}) {
  for (var friendId in FRIEND_LIST) {
    //
    // 範囲内かどうかを判定する関数を呼び出し
    if (FRIEND_LOCATION[friendId] != null &&
        _isWithinRange(MY_LOCATION, FRIEND_LOCATION[friendId]!, range)) {
      if (TAG_LIST[friendId] != null) {
        // 近くにいる友達のIDを保存
          final updatedSet =
            LinkedHashSet<String>.from(FRIEND_EXCHANGE.value);
        updatedSet.add(friendId);
        FRIEND_EXCHANGE.value = updatedSet;
        if (NEARBY_IDS.contains(friendId) == false) {
          //IDを一時的に保存
          NEARBY_IDS.add(friendId);

          // 通知を出す
          String title = "近くに友達がいます。";
          String message = "${TAG_LIST[friendId]!['名前']}さんが近くにいます。";
          showLocalNotification(title, message);
        }
      }
    }
    if (_isWithinRange(MY_LOCATION, FRIEND_LOCATION[friendId]!, range) ==
            false &&
        NEARBY_IDS.contains(friendId)) {
      NEARBY_IDS.remove(friendId);
    }
  }
}

// ２点間の距離が範囲内かどうかを判定する関数
bool _isWithinRange(GeoPoint loc1, GeoPoint loc2, double range) {
  // ２点間の距離を計算（メートル）
  double distance = Geolocator.distanceBetween(
      loc1.latitude, loc1.longitude, loc2.latitude, loc2.longitude);

  // 距離が指定範囲内かどうかを判定
  return distance <= range;
}
