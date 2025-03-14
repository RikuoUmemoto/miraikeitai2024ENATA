/* DropBox を利用した画像の保存、取得処理を行うファイル */

/*  --処理手順--
    アクセストークン取得
    1. アクセストークンを取得＆期限チェック
    2. 期限切れの場合　→　リフレッシュトークンを利用して生成＆更新

    保存
    1. DropBoxに画像をアップロード(uploadToDropbox)
    2. Firestore にファイルパスを保存(saveImagePathToFirestore)
    
    取得
    1. Firestoreからファイルパスを取得(getPathFromFirestore)
    2. DropBoxから画像をダウンロード(downloadFromDropbox)          */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enata/data_store.dart';

class ProfileImageHandler {
  //---------------------アクセストークン処理----------------------

  String? accessToken; // DropBoxアクセストークン
  String? refreshToken; // DropBoxリフレッシュトークン
  DateTime? _lastUpdated; // 最後にアクセストークンを更新した日時
  Timer? _refreshTimer; // 定期的な更新用のタイマー
  final storage = FlutterSecureStorage();

  // アクセストークンを保存
  Future<void> saveAccessToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  // アクセストークンを取得
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  // リフレッシュトークンを保存
  Future<void> saveRefreshToken(String refreshToken) async {
    await storage.write(key: 'refresh_token', value: refreshToken);
  }

  // リフレッシュトークンを取得
  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }

  // 新しいアクセストークンを取得（格納もする）
  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/oauth2/token'),
      headers: {
        'Authorization': 'Basic ' +
            //ダミー値
            base64Encode(utf8.encode('your_client_id:your_client_secret')),
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String newAccessToken = responseData['access_token'];
      await saveAccessToken(newAccessToken); // 新しいアクセストークンを保存
      print('update AccessToken');
      _lastUpdated = DateTime.now(); // 更新した時刻を記録
      return newAccessToken;
    } else {
      throw Exception('failed to update AccessToken');
    }
  }

  // 現在のアクセストークンを取得＆期限をチェック→更新
  Future<String> getValidAccessToken() async {
    accessToken = await getAccessToken(); // 現在のアクセストークンを取得
    if (accessToken == null) {
      throw Exception('not saved AccessToken');
    }
    bool isExpired = await isAccessTokenExpired(); // 更新の必要性を確認する処理
    if (isExpired) {
      refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        // リフレッシュトークンを使ってアクセストークンを更新
        return await refreshAccessToken(refreshToken!);
      } else {
        throw Exception('not saved RefreshToken');
      }
    } else {
      return accessToken!; // 期限切れでなければそのままアクセストークンを返す
    }
  }

  // 更新の必要性を確認する関数
  Future<bool> isAccessTokenExpired() async {
    // アクセストークンの取得日時を確認
    if (_lastUpdated == null ||
        DateTime.now().difference(_lastUpdated!).inHours >= 3) {
      print("update AccessToken because of first boot or expired token");
      return true; // 要更新
    } else {
      print("still effective");
      return false; // 更新不要
    }
  }

  // 更新する場合のHTTPリクエスト送信関数
  Future<void> makeApiRequest() async {
    try {
      String accessToken = await getValidAccessToken();
      final response = await http.get(
        Uri.parse('https://api.dropboxapi.com/2/files/list_folder'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        print('Success API request: ${response.body}');
      } else {
        print('failed API request: ${response.body}');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  // ３時間ごとの定期更新を開始
  void startTokenRefreshTimer() {
    _refreshTimer?.cancel(); // 既存のタイマーをキャンセル
    _refreshTimer = Timer.periodic(Duration(hours: 3), (timer) async {
      await refreshAccessToken(refreshToken!);
    });
    print('start regular updating AccessToken');
  }

  // タイマーを停止する
  void stopTokenRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    print('stop regular updating AccessToken');
  }

  // 初期化処理　必要に応じてトークンを更新し、タイマーを開始
  Future<void> initializeTokenManager() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw Exception("RefreshToken is null");
    } else {
      final newAccessToken = await refreshAccessToken(refreshToken); // 起動時に必ず更新
      saveAccessToken(newAccessToken);
    }
    startTokenRefreshTimer(); // その後4時間ごとの更新を開始
  }

  // ----------------DropBoxとの画像保存・取得処理--------------------------------

  // ローカル画像をDropBoxにアップロード
  Future<String> uploadToDropbox(File file, String fileName) async {
    accessToken = await getAccessToken();
    // http を利用して DropBox の /files/upload エンドポイントに画像を送信
    final url = 'https://content.dropboxapi.com/2/files/upload';
    // ヘッダーに必要な認証情報(Authorization)とリクエスト(Content-Type,Dropbox-API-Arg)を設定
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/octet-stream',
      'Dropbox-API-Arg': jsonEncode(
        {
          "path": "/$fileName", // DropBox内で画像を保存するパス
          "mode": "add", // ファイルが既存する場合、新規ファイルとして追加(add)
          "autorename": true, // 同名ファイルが存在する場合、自動的に名前を変更する
          "mute": false,
        },
      ),
    };
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: file.readAsBytesSync(), // ファイルをバイナリ形式で送信
    );
    if (response.statusCode == 200) {
      // アップロード成功の場合
      final jsonResponse = jsonDecode(response.body); // JSONレスポンスを解析して、
      saveImagePathToFirestore(
          USER_ID, jsonResponse['path_display']); // ファイルパスをfirestoreに保存
      print('success upload');
      return jsonResponse['path_display'];
    } else {
      // アップロード失敗の場合
      print('failed upload');
      throw Exception('Failed to upload image: ${response.body}');
    }
  }

// FirestoreにDropbox画像パスを保存
  Future<void> saveImagePathToFirestore(String userId, String imagePath) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update(
      {
        'profileImagePath1': imagePath,
      },
    );
  }

// Dropboxから画像を取得して変数に格納
// 返す値はUint8List型(= 画像データがバイナリ形式でメモリ上に保持されている状態)
// ↳ 取得した画像はローカルストレージにダウンロードせず、変数に持たせるため
// この関数は直接呼ばない。getPathFromFirestore()から呼ばれる。
  Future<Uint8List> downloadFromDropbox(String filePath) async {
    accessToken = await getAccessToken();
    // Dropboxの/files/downloadエンドポイントを指定
    final url = 'https://content.dropboxapi.com/2/files/download';
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Dropbox-API-Arg': jsonEncode({
        "path": filePath,
      }),
    };
    // POST リクエストで画像ファイルを取得する(上記エンドポイントに送信する)
    final response = await http.post(Uri.parse(url), headers: headers);

    // 取得が成功した場合
    if (response.statusCode == 200) {
      print('Download successful for path: $filePath'); // デバッグログ
      return response.bodyBytes; // バイナリデータ（Uint8List型）を返す
    } else {
      // 取得が失敗した場合
      print(
          'Failed to download image. Status: ${response.statusCode}, Body: ${response.body}'); // デバッグログ
      throw Exception('Failed to download image: ${response.body}');
    }
  }

// FirestoreからDropboxファイルパスを取得して画像をダウンロード
  Future<Uint8List?> getPathFromFirestore(String userId) async {
    try {
      // Firestoreからユーザーのドキュメントを取得
      final fbHandler = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // imageNumberによって異なるフィールドを参照
      String? filePath;
      filePath = fbHandler.data()?['profileImagePath1']; // 画像1のパス取得

      if (filePath != null) {
        // Dropboxから画像を取得
        final imageBytes = await downloadFromDropbox(filePath);
        print('Image downloaded successfully for user $userId'); // デバッグログ
        return imageBytes;
      } else {
        print('No file path found in Firestore for user $userId'); // デバッグログ
        return null;
      }
    } catch (e) {
      print('Error getting image from Firestore: $e'); // デバッグログ
      return null;
    }
  }
}
