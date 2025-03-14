/*-----------------
通知機能の処理ファイル
------------------*/

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void showLocalNotification(String title, String message) {
  // android 通知の設定
  const androidNotificationDetail = AndroidNotificationDetails(
      'channelId', // channel Id 通知のカテゴリを識別
      'channelName' // channel Name 通知チャンネル名で、ユーザに表示されることがあるらしい
      );
  // ios 通知の設定
  const iosNotificationDetail =
      DarwinNotificationDetails(); // DarwinNotificationDetailsはios通知に関する設定を行うクラス（今回は設定していない）

  //通知のプラットフォーム別に設定する
  const notificationDetails = NotificationDetails(
    iOS: iosNotificationDetail,
    android: androidNotificationDetail,
  );

  // 通知を表示する
  // .show(通知のID, 通知のタイトル, 通知のメッセージ, 適用する通知の詳細設定)
  FlutterLocalNotificationsPlugin()
      .show(0, title, message, notificationDetails);
}
