//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post/post.dart';
import '../providers/posts_provider.dart';
import '../references.dart';
import '../widgets/post_widget.dart';
//import 'profile_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  Future<void> sendPost(String text) async {
    // まずは user という変数にログイン中のユーザーデータを格納します
    final user = FirebaseAuth.instance.currentUser!;

    final posterId = user.uid; // ログイン中のユーザーのIDがとれます
    final posterName = user.displayName!; // Googleアカウントの名前がとれます
    final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます

    final newPost = Post(
      text: text,
      createdAt: null, // null を入れると ServerTimestamp を参照することになっています。
      posterName: posterName,
      posterImageUrl: posterImageUrl,
      posterId: posterId,
      // doc の引数を空にするとランダムなIDが採番されます
      reference: postsReferenceWithConverter.doc(),
    );

    // 先ほど作った newDocumentReference のset関数を実行するとそのドキュメントにデータが保存されます。
    // 引数として Post インスタンスを渡します。
    // 通常は Map しか受け付けませんが、withConverter を使用したことにより Post インスタンスを受け取れるようになります。
    await newPost.reference.set(newPost);
  }

  // build の外でインスタンスを作ります。
  final controller = TextEditingController();

  /// この dispose 関数はこのWidgetが使われなくなったときに実行されます。
  @override
  void dispose() {
    // TextEditingController は使われなくなったら必ず dispose する必要があります。
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold 全体を GestureDetector で囲むことでタップ可能になります。
    return GestureDetector(
      onTap: () {
        // キーボードを閉じたい時はこれを呼びます。
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チャット'),
          // actions プロパティにWidgetを与えると右端に表示されます。
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      //return const ProfilePage();
                      return const ChatPage();
                    },
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser!.photoURL!,
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              //Riverpodを使って、プロバイダから情報を監視するための処理
              //postsProviderから提供されたデータの変化を監視し、そのデータを元にUIを変更する
              //whenメソッドで、非同期処理の結果に基づいて、それぞれの処理を実施するよう定義する
              child: ref.watch(postsProvider).when(
                //whenプロパティであるdata, error, loadingでそれぞれの状態に関する処理を行う
                //データを正常取得できたときの処理
                //data引数に取得したデータが入る
                data: (data) {
                  return ListView.builder(
                    itemCount: data.docs.length,
                    itemBuilder: (context, index) {
                      final post = data.docs[index].data();
                      return PostWidget(post: post);
                    },
                  );
                },
                //エラー発生時の処理
                error: (_, __) {
                  return const Center(
                    child: Text('不具合が発生しました'),
                  );
                },
                //ローディング中の処理
                loading: () {
                  return const Center(
                    //ロード中であるインジケーターを表示
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            // Expanded(
            //   child: StreamBuilder<QuerySnapshot<Post>>(
            //     // stream プロパティに snapshots() を与えると、コレクションの中のドキュメントをリアルタイムで監視することができます。
            //     stream: postsReferenceWithConverter
            //         .orderBy('createdAt')
            //         .snapshots(),
            //     // ここで受け取っている snapshot に stream で流れてきたデータ入っています。
            //     builder: (context, snapshot) {
            //       // docs には Collection に保存されたすべてのドキュメントが入ります。
            //       // 取得までには時間がかかるのではじめは null が入っています。
            //       // null の場合は空配列が代入されるようにしています。
            //       final docs = snapshot.data?.docs ?? [];
            //       return ListView.builder(
            //         itemCount: docs.length,
            //         itemBuilder: (context, index) {
            //           // data() に Post インスタンスが入っています。
            //           // これは withConverter を使ったことにより得られる恩恵です。
            //           // 何もしなければこのデータ型は Map になります。
            //           final post = docs[index].data();
            //           return PostWidget(post: post);
            //         },
            //       );
            //     },
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                // 上で作ったコントローラーを与えます。
                controller: controller,
                decoration: InputDecoration(
                  // 未選択時の枠線
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                  // 選択時の枠線
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.amber,
                      width: 2,
                    ),
                  ),
                  // 中を塗りつぶす色
                  fillColor: Colors.amber[50],
                  // 中を塗りつぶすかどうか
                  filled: true,
                ),
                onFieldSubmitted: (text) {
                  sendPost(text);
                  // 入力中の文字列を削除します。
                  controller.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
