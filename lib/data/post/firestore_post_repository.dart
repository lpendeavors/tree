import '../../models/post_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestorePostRepository {
  Stream<PostEntity> postById({
    @required String postId,
  });

  Stream<List<PostEntity>> posts({
    @required String uid,
    @required bool isAdmin,
  });

  Future<Map<String, String>> savePost(PostEntity post);
}