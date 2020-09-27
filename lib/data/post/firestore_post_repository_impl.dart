import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import './firestore_post_repository.dart';
import '../../models/old/post_entity.dart';

class FirestorePostRepositoryImpl implements FirestorePostRepository {
  final Firestore _firestore;
  final FirebaseStorage _storage;

  const FirestorePostRepositoryImpl(
    this._firestore,
    this._storage,
  );

  @override
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
  ) async {
    final post = <String, dynamic>{
      'byAdmin': byAdmin,
      'churchName': ownerIsChurch ? ownerName : '',
      'fullName': ownerIsChurch ? '' : ownerName,
      'image': ownerImage,
      'isAdmin': ownerIsAdmin,
      'isChurch': ownerIsChurch,
      'isGroup': groupId == null ? false : true,
      'postId': groupId == null ? '' : groupId,
      'isHidden': isHidden,
      'isPostPrivate': isPrivate,
      'isVerified': isVerified,
      'ownerId': ownerId,
      'parties': parties,
      'postMessage': message,
      'pushNotificationToken': ownerNotificationToken,
      'tags': tagged,
      'timeUpdated': DateTime.now().millisecondsSinceEpoch,
      'tokenID': ownerNotificationToken,
      'uid': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (postId != null) {
      await _firestore
          .collection('postBase')
          .document(postId)
          .setData(post, merge: true);
    } else {
      List<String> imageUrls = await Future.wait(
        media.map((image) async {
          String id = Uuid().v1();
          StorageReference storageRef = _storage.ref().child(id);
          StorageUploadTask upload = storageRef.putFile(File(image));
          StorageTaskSnapshot task = await upload.onComplete;
          String url = await task.ref.getDownloadURL();

          return url;
        }).toList(),
      );

      post.addAll({
        'time': DateTime.now().millisecondsSinceEpoch,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
        'isReported': false,
        'type': 0,
        'visiblity': 0,
      });

      if (media.isNotEmpty) {
        post.addAll({
          'postData': imageUrls.map((media) {
            return {
              'imageUrl': media,
              'type': mediaType + 1,
            };
          }).toList(),
        });
      }

      await _firestore.collection('postBase').add(post);
    }
  }

  @override
  Stream<PostEntity> postById({String postId}) {
    return _firestore
        .collection('postBase')
        .document(postId)
        .snapshots()
        .map((snapshot) => PostEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Stream<List<PostEntity>> postsByUser({
    String uid,
  }) {
    return _firestore
        .collection('postBase')
        .where('parties', arrayContains: uid)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> postsByOwner({
    String uid,
  }) {
    return _firestore
        .collection('postBase')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> getByAdmin() {
    return _firestore
        .collection('postBase')
        .where('byAdmin', isEqualTo: true)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> postsForCollage() {
    return _firestore
        .collection('postBase')
        .where('isVerified', isEqualTo: true)
        //.where('postData', isNull: false)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> getByGroup(String postId) {
    return _firestore
        .collection('postBase')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map(_toEntities);
  }

  List<PostEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return PostEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Future<void> likeOrUnlikePost(
      {bool shouldLike, String postId, String userId}) async {
    if (shouldLike) {
      return _firestore.document('postBase/$postId').updateData({
        'likes': FieldValue.arrayUnion([userId])
      });
    } else {
      return _firestore.document('postBase/$postId').updateData({
        'likes': FieldValue.arrayRemove([userId])
      });
    }
  }

  @override
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
  ) async {
    final poll = <String, dynamic>{
      'byAdmin': byAdmin,
      'country': '',
      'createdAt': null,
      'email': '',
      'fullName': ownerName,
      'gender': 0,
      'image': ownerImage,
      'isAdmin': byAdmin,
      'isGroup': isGroup,
      'isHidden': isHidden,
      'isPoll': true,
      'isQuiz': pollType == 1 ? true : false,
      'isVerified': ownerVerified,
      'ownerId': ownerId,
      'parties': parties,
      'pollData': answers,
      'pollDuration': [
        DateTime.now().millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch
      ],
      'postMessage': question,
      'tags': tags,
      'timeUpdated': DateTime.now().millisecondsSinceEpoch,
      'tokenID': ownerToken,
      'type': 2,
      'uid': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
      'userImage': ownerImage,
      'visibility': 0,
    };

    if (pollId != null) {
      await _firestore
          .collection('postBase')
          .document(pollId)
          .setData(poll, merge: true);
    } else {
      poll.addAll({
        'isReported': false,
        'createdAt': FieldValue.serverTimestamp(),
        'time': DateTime.now().millisecondsSinceEpoch,
        'likes': [],
      });

      if (groupId != null) {
        poll.addAll({'postId': groupId});
      }

      await _firestore.collection('postBase').add(poll);
    }
  }

  @override
  Future<void> deletePost(String postId) {
    return _firestore.collection('postBase').document(postId).delete();
  }
}
