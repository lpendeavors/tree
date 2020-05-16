import '../../models/old/post_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestorePostRepository {
  Stream<PostEntity> postById({
    @required String postId,
  });

  Stream<List<PostEntity>> posts({
    @required String uid,
  });

  Stream<List<PostEntity>> postsForCollage();

  Stream<List<PostEntity>> getByAdmin();

  Future<Map<String, String>> savePost(PostEntity post);
}