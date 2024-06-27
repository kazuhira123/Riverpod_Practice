import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post/post.dart';
import 'firestore_provider.dart';

final postsReferenceProvider = Provider((ref) {
  final firestore = ref.read(firestoreProvider);
  return firestore.collection('posts').withConverter<Post>(
      fromFirestore: ((snapshot, _) {
    return Post.fromFirestore(snapshot);
  }), toFirestore: ((value, _) {
    return value.toMap();
  }));
});
