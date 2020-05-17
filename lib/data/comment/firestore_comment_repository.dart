import '../../models/old/comment_entity.dart';

abstract class FirestoreCommentRepository {
  Stream<List<CommentEntity>> getByPost(String postId);
}