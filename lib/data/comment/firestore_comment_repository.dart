import '../../models/old/comment_entity.dart';

abstract class FirestoreCommentRepository {
  Stream<List<CommentEntity>> getByPost(String postId);

  Future<Map<String, String>> saveComment(
    String commentId,
    bool byAdmin,
    String ownerName,
    bool ownerIsAdmin,
    bool ownerIsChurch,
    String ownerImage,
    bool ownerVerified,
    String ownerId,
    String postId,
    String postMessage,
    bool isGif,
    String gif,
    String ownerToken,
  );
}
