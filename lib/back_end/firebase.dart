/*------------------------------------
ファイアベース（データベース）の処理ファイル
-------------------------------------*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:enata/data_store.dart';
import 'dart:collection';
import 'dart:typed_data';
import 'package:enata/back_end/dropbox.dart';

// Firestoreにデータを登録する関数
Future<void> setData(String key, Map<String, dynamic> data) async {
  try {
    // Firestoreにデータを保存する処理
    await FirebaseFirestore.instance.collection('users').doc(key).set(
      {
        ...data,
        '更新日時': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 同時にローカルのデータも更新する（setDataは自分のデータしか編集しないこと前提）
    // dataにフィールド自体がない場合は書き換えない
    data.forEach(
      (key, value) {
        TAG_LIST[USER_ID]![key] = value;
      },
    );
  } catch (e) {
    print('データの登録に失敗しました : $e');
  }
}

// Firestoreからデータを取得する関数
Future<Map<String, dynamic>?> getData(String key) async {
  try {
    // 指定されたキーのデータを取得
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(key).get();

    // データが存在する場合はデータをを返し、存在しない場合はnullを返す
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>?;
    } else {
      return null;
    }
  } catch (e) {
    print('データの取得に失敗しました : $e');
    return null;
  }
}

// 新規登録時、Firestoreにデータを登録する関数
Future<void> createAccount(Map<String, dynamic> data) async {
  try {
    // Firestoreにデータを保存する処理
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(USER_ID).set(
        {
          'email': FirebaseAuth.instance.currentUser!.email,
          '作成日時': FieldValue.serverTimestamp(),
          ...data,
        },
      );
    } else {
      print('ログインしてください');
    }
  } catch (e) {
    print('データの登録に失敗しました : $e');
  }
}

// 友達を追加する関数（自分のキーは固定値として設定）
Future<void> addFriend(String myKey, String friendKey) async {
  try {
    // ユーザードキュメントへの参照
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(myKey);
    //フレンドドキュメントへの参照
    DocumentReference friendDocRef =
        FirebaseFirestore.instance.collection('users').doc(friendKey);

    // 友達リストに追加
    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userDocRef);

        // 友達のドキュメントを取得
        DocumentSnapshot friendSnapshot = await friendDocRef.get();

        // 現在の友達リスト
        List<dynamic> friendList = [];

        // 「友達リスト」が存在しない場合、空のリストで初期化
        final docData = userSnapshot.data() as Map<String, dynamic>;
        if (userSnapshot.exists && !docData.containsKey('友達リスト')) {
          transaction.update(userDocRef, {'友達リスト': []});
        } else {
          friendList = userSnapshot['友達リスト'];
        }

        // 友達のキーがDBに存在するか確認
        if (!friendSnapshot.exists) {
          print('友達のキーが存在しません: $friendKey');
          return; // 友達が存在しない場合は処理を終了
        }

        if (userSnapshot.exists) {
          // すでに友達が追加されていないか確認して追加
          if (!friendList.contains(friendKey)) {
            friendList.add(friendKey);
            transaction.update(userDocRef, {'友達リスト': friendList});

            // ローカルのリストにも追加
            final updatedSet =
                LinkedHashSet<String>.from(FRIEND_EXCHANGE.value);
            updatedSet.add(friendKey);
            FRIEND_EXCHANGE.value = updatedSet;
            FRIEND_LIST.add(friendKey);
            TAG_LIST[friendKey] = await getData(friendKey) ?? {};

            // 相手の写真もローカルへ
            final dropBoxHandler = ProfileImageHandler();
            Uint8List? image =
                await dropBoxHandler.getPathFromFirestore(friendKey);
            FRIEND_IMAGES[friendKey] = image!;
          }
        }
      },
    );
  } catch (e) {
    print('友達の追加に失敗しました: $e');
  }
}

// 友達リストを取得する関数
Future<List<String>> getFriendList(String myKey) async {
  try {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(myKey).get();

    if (snapshot.exists) {
      List<dynamic> friendList = snapshot['友達リスト'] ?? [];
      return List<String>.from(friendList);
    } else {
      print('データが見つかりませんでした');
      return [];
    }
  } catch (e) {
    print('友達リストの取得に失敗しました : $e');
    return [];
  }
}
