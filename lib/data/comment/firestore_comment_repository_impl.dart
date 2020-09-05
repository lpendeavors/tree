import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import './firestore_comment_repository.dart';
import '../../models/old/comment_entity.dart';

class FirestoreCommentRepositoryImpl implements FirestoreCommentRepository {
  final Firestore _firestore;
  final FirebaseStorage _storage;

  const FirestoreCommentRepositoryImpl(
    this._firestore,
    this._storage,
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
    return querySnapshot.documents.map((documentSnapshot) {
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
      'updatedAt': FieldValue.serverTimestamp(),
      'userImage': ownerImage,
      'visibility': 0,
      'isGIF': isGif,
    };

    if (commentId != null) {
      // if (isReply) {
      //   await _firestore.document('commentsBase/$commentId').updateData({
      //     'replies': FieldValue.arrayUnion([
      //       <String, dynamic>{
      //         'test': 'working',
      //         'works': true,
      //       }
      //     ]),
      //   });
      // } else {
      // await _firestore
      //     .collection('commentsBase')
      //     .document(commentId)
      //     .setData(comment, merge: true);
      // }
    } else {
      if (isGif) {
        // String id = Uuid().v1();
        // StorageReference storageRef = _storage.ref().child(id);
        // StorageUploadTask upload = storageRef.putFile(File(gif));
        // StorageTaskSnapshot task = await upload.onComplete;
        // String url = await task.ref.getDownloadURL();

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
      return _firestore.document('commentsBase/$commentId').updateData({
        'likes': FieldValue.arrayUnion([uid])
      });
    } else {
      return _firestore.document('commentsBase/$commentId').updateData({
        'likes': FieldValue.arrayRemove([uid])
      });
    }
  }
}
