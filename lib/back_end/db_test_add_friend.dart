import 'package:flutter/material.dart';
import 'package:enata/data_store.dart';
import 'firebase.dart';

class FriendAddTest extends StatefulWidget {
  const FriendAddTest({super.key});

  @override
  _FriendAddTestState createState() => _FriendAddTestState();
}

class _FriendAddTestState extends State<FriendAddTest> {
  // 友達のキー用のテキストコントローラー
  final TextEditingController _friendKeyController = TextEditingController();
  List<String> _friendList = []; // 取得した友達リストを保持

  @override
  void dispose() {
    // 使用が終わったコントローラーを解放
    _friendKeyController.dispose();
    super.dispose();
  }

  // 友達を追加する関数
  Future<void> _addFriend() async {
    final friendKey = _friendKeyController.text;
    if (friendKey.isNotEmpty) {
      await addFriend(USER_ID, friendKey);
      _friendKeyController.clear();
    } else {
      print('友達のキーが入力されていません');
    }
  }

  // 友達リストを取得する関数
  Future<void> _fetchFriendList() async {
    final friendList = await getFriendList(USER_ID);
    setState(
      () {
        _friendList = friendList;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('友達追加テストページ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 友達のキーを入力するテキストフィールド
            TextField(
              controller: _friendKeyController,
              decoration: const InputDecoration(
                labelText: '友達のキー',
                hintText: '追加したい友達のキーを入力してください',
                prefixIcon: Icon(Icons.group_add),
              ),
            ),
            const SizedBox(height: 20),

            // 友達を追加するボタン
            ElevatedButton(
              onPressed: _addFriend,
              child: const Text('友達を追加'),
            ),

            const SizedBox(height: 20),

            // 友達リストを取得するボタン
            ElevatedButton(
              onPressed: _fetchFriendList,
              child: const Text('友達リストを取得'),
            ),

            const SizedBox(height: 20),

            // 取得した友達リストの表示
            Expanded(
              child: ListView.builder(
                itemCount: _friendList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_friendList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
