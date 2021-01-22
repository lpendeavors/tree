import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './firestore_comment_repository.dart';
import '../../models/old/comment_entity.dart';

class FirestoreCommentRepositoryImpl implements FirestoreCommentRepository {
  final FirebaseFirestore _firestore;

  const FirestoreCommentRepositoryImpl(
    this._firestore,
  );

  @override
  Stream<List<CommentEntity>> getByPost(String postId) {
    return _firestore
        .collection('commentsBase')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map(_toEntities);
  }

  List<CommentEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((documentSnapshot) {
      return CommentEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
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
    bool isReply,
  ) async {
    var comment = <String, dynamic>{
      'byAdmin': byAdmin,
      'country': '',
      'fullName': ownerName,
      'image': ownerImage,
      'isChurch': ownerIsChurch,
      'isVerified': ownerVerified,
      'ownerId': ownerId,
      'postId': postId,
      'postMessage': postMessage,
      'pushNotificationToken': ownerToken,
      'timeUpdated': DateTime.now().millisecondsSinceEpoch,
      'tokenID': ownerToken,
      'uid': ownerId,
      'userImage': ownerImage,
      'visibility': 0,
      'isGIF': isGif,
    };

    if (commentId.isNotEmpty) {
      if (isReply) {
        comment.addAll({'time': DateTime.now().millisecondsSinceEpoch});
        await _firestore.doc('commentsBase/$commentId').update({
          'replies': FieldValue.arrayUnion([
            comment,
          ]),
        });
      } else {
        comment.addAll({'updatedAt': FieldValue.serverTimestamp()});
        await _firestore
            .collection('commentsBase')
            .doc(commentId)
            .set(comment, SetOptions(merge: true));
      }
    } else {
      if (isGif) {
        comment.addAll({
          'imagePath': gif,
        });
      }

      comment.addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'time': DateTime.now().millisecondsSinceEpoch,
        'likes': [],
        'replies': [],
      });

      await _firestore.collection('commentsBase').add(comment);
    }
  }

  @override
  Future<void> likeOrUnlikeComment(
      String commentId, bool shouldLike, String uid) async {
    if (shouldLike) {
      return _firestore.doc('commentsBase/$commentId').update({
        'likes': FieldValue.arrayUnion([uid])
      });
    } else {
      return _firestore.doc('commentsBase/$commentId').update({
        'likes': FieldValue.arrayRemove([uid])
      });
    }
  }
}
