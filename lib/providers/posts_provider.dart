import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../references.dart';

//全投稿をstreamで提供するProvider
final postsProvider = StreamProvider((ref) {
  return postsReferenceWithConverter.orderBy('createdAt').snapshots();
});
