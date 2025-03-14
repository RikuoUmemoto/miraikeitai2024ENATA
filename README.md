## miraikeitai2024ENATA
本リポジトリは、ミライケータイプロジェクトで開発したFlutterアプリケーション「ENATA」のソースコードです。

## コーディングルール  
**(見やすいコードを書きましょう！)**

1,ファイル名とクラス名は一致させる（ファイル名：home_page、クラス名：HomePage）<br>  
2,**ファイル名、ディレクトリ名**：単語間にアンダーバーを挿入する（例：home_page）  
3,**クラス名**：単語の頭だけ大文字にする（例：HomePage）  
4,**変数名**：　先頭は小文字、その後は各単語の頭を大文字にする（例：userName）  
5,**定数名**：　すべて大文字、単語間はアンダーバー（例：USER_NAME）<br>  

6,インデント、改行  
インデントはTabを使う  
おそらく"ctrl+S"で自動的に整います  
**NG**
```
someFunc(color: Colors.blue,fontSize: 16.0,);
```
**OK**
```
someFunc(
  color: Colors.blue,
  fontSize: 16.0,
);
``` 
<br>  
7,コメント<br>
明確にコメント量を指定できませんが、自分が所見で見たときに困らない程度にコメントを入れてください<br>
// とコメント本文の間は半角スペースひとつ開ける  

```  
// ページ上部のバーの設定
appBar: AppBar(
  title: const Text('ホーム'),
  
  // 前のページに戻るボタン
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context); // 前のページに戻る
    },
  ),
),
```
<br>  

## githubを使用した作成の流れ
１、projectsの”ToDo”にタスクの作成、担当割り当て  
２、自分のタスクを”In Progress”へ移動  
３、issuesの作成  
４、作成したissuesで、Assignees、Labelsの設定  
&emsp;&emsp;a、Assignees（割り当て対象者）  
&emsp;&emsp;b、Labels（issuesのラベル)  
５、issuesのDevelopmentで”Create a branch”を押し、branchの作成
（ブランチ名の末尾に自分の名前をつける、例："OOの修正-tanaka"）<br>  

６、自分のブランチでコーディング  
&emsp;（終了後）<br>  

７、変更のステージング、コミット、プッシュ  
&emsp;（これらは作業の区切りや１日の作業の終わりなど何度もやるもの！）  
&emsp;Git 作業における commit と push の頻度について<br>  
（タスクが一通り完了したら）<br>  
８、プルリクエストの作成  
&emsp;&emsp;a、説明は記入してください（〇〇ファイルを作成した、機能を追加した、このような方針で作成した、〇〇を参考にしたなど、レビュワーが困らないように（レビュワーにメンション！））  
&emsp;&emsp;b、Reviewersを指定（近しい作業をしている人だとやりやすい）  
&emsp;&emsp;c、Assigneesをレビュワーに変更（できればissuesの方も）  
９、レビュワーはコードを確認  
&emsp;&emsp;a、問題なければマージしてプルリクエストを閉じる。  
&emsp;&emsp;b、ダメだった時は、プルリクエストの場所にメンションしてコメントし、Assigneesを変更します。  

１０、マージされたことを確認して終了。（コードをマージした時点で、自動で関連しているissuesは閉じ、タスクも”Done”に移動するはずです）  

## レビューをお願いする際に記載すること。
１、変更したファイル名の記載
２、テストをする際にどのような動作をしてどのような結果を確認してほしいか

<br>  

## ヘルプ  
**以下は、flutterの開発元？が出しているヘルプです。サンプルコードなどもあります**<br>
これが初めてのFlutterプロジェクトであれば、いくつかのリソースから始めましょう：<br>
- [Lab: 初めてのFlutterアプリを書く](https://docs.flutter.dev/get-started/codelab)<br>
- クックブック：便利なFlutterサンプル](https://docs.flutter.dev/cookbook)<br>

Flutter開発を始めるためのヘルプは、以下を参照してください。<br>
[オンラインドキュメント](https://docs.flutter.dev/)をご覧ください、チュートリアル、サンプル、モバイル開発に関するガイダンス、完全なAPIリファレンスがあります。<br>
