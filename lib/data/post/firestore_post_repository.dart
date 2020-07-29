import '../../models/old/post_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestorePostRepository {
  Stream<PostEntity> postById({
    @required String postId,
  });

  Stream<List<PostEntity>> postsByUser({
    @required String uid,
  });

  Stream<List<PostEntity>> postsByOwner({
    @required String uid,
  });

  Stream<List<PostEntity>> getByGroup(String postId);

  Stream<List<PostEntity>> postsForCollage();

  Stream<List<PostEntity>> getByAdmin();

  Future<Map<String, String>> savePost(
    String postId,
    bool byAdmin,
    String ownerName,
    String ownerImage,
    bool ownerIsAdmin,
    bool ownerIsChurch,
    bool ownerIsGroup,
    bool isHidden,
    int isPrivate,
    bool isReported,
    bool isVerified,
    String ownerId,
    List<String> parties,
    List<String> media,
    int mediaType,
    String message,
    String ownerNotificationToken,
    int type,
    String groupId,
    List<String> tagged,
  );

  Future<Map<String, String>> savePoll(
    String pollId,
    String groupId,
    bool byAdmin,
    String ownerId,
    String ownerName,
    String ownerImage,
    String ownerToken,
    bool ownerVerified,
    bool isGroup,
    bool isHidden,
    bool isQuiz,
    bool isVerified,
    List<String> parties,
    List<Map<String, dynamic>> answers,
    DateTime endDate,
    String question,
    List<String> tags,
    int pollType,
  );

  Future<void> likeOrUnlikePost({
    @required bool shouldLike,
    @required String postId,
    @required String userId,
  });
}
