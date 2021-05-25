import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/notification_util.dart';
import 'package:uuid/uuid.dart';
import './firestore_post_repository.dart';
import '../../models/old/post_entity.dart';

class FirestorePostRepositoryImpl implements FirestorePostRepository {
  final FirebaseFirestore _firestore;
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
      'isHidden': isHidden,
      'isPostPrivate': isPrivate,
      'isVerified': isVerified,
      'ownerId': ownerId,
      'postMessage': message,
      'pushNotificationToken': ownerNotificationToken,
      'tags': tagged,
      'timeUpdated': DateTime.now().millisecondsSinceEpoch,
      'tokenID': ownerNotificationToken,
      'uid': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (groupId != null) {
      post.addAll({
        'parties': List<String>(),
        'postId': groupId,
      });
    } else {
      post.addAll({
        'parties': parties,
      });
    }

    if (postId != null) {
      await _firestore
          .collection('postBase')
          .doc(postId)
          .set(post, SetOptions(merge: true));
    } else {
      List<String> imageUrls = await Future.wait(
        media.map((image) async {
          String id = Uuid().v1();
          Reference storageRef = _storage.ref().child(id);
          UploadTask upload = storageRef.putFile(File(image));
          TaskSnapshot task = await upload;
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
    }

    await _firestore.collection('postBase').add(post);
  }

  @override
  Stream<PostEntity> postById({String postId}) {
    return _firestore
        .collection('postBase')
        .doc(postId)
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
        .where('isGroup', isEqualTo: false)
        .orderBy('time', descending: true)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> getByAdmin() {
    return _firestore
        .collection('postBase')
        // .where('byAdmin', isEqualTo: true)
        .where('isGroup', isEqualTo: false)
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
    return querySnapshot.docs.map((documentSnapshot) {
      return PostEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Future<void> likeOrUnlikePost({
    bool shouldLike,
    String postId,
    String userId,
  }) async {
    if (shouldLike) {
      return _firestore.doc('postBase/$postId').update({
        'likes': FieldValue.arrayUnion([userId])
      });
    } else {
      return _firestore.doc('postBase/$postId').update({
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
          .doc(pollId)
          .set(poll, SetOptions(merge: true));
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
    return _firestore.collection('postBase').doc(postId).delete();
  }

  @override
  Future<void> sharePost(
    String postId,
    bool byAdmin,
    String ownerId,
    String ownerName,
    String ownerEmail,
    String ownerImage,
    String ownerToken,
    bool ownerVerified,
    bool isChurch,
    String message,
    List<String> parties,
  ) async {
    var post = await _firestore.doc('postBase/$postId').snapshots().first;

    var newPost = <String, dynamic>{
      'sharedPost': post.data(),
      'byAdmin': byAdmin,
      'churchName': isChurch ? ownerName : '',
      'createdAt': FieldValue.serverTimestamp(),
      'email': ownerEmail,
      'fullName': isChurch ? '' : ownerName,
      'image': ownerImage,
      'isChurch': isChurch,
      'isHidden': true,
      'isReported': false,
      'isShared': true,
      'isGroup': false,
      'isVerified': ownerVerified,
      'ownerId': ownerId,
      'pushNotificationToken': ownerToken,
      'time': DateTime.now().millisecondsSinceEpoch,
      'timeUpdated': DateTime.now().millisecondsSinceEpoch,
      'tokenID': ownerToken,
      'uid': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
      'visibility': 0,
      'postMessage': message,
    };

    await _firestore.collection('postBase').add(newPost);
  }

  @override
  Future<void> answerPoll(
    String pollId,
    int answerIndex,
    String userId,
  ) async {
    var postRef = _firestore.doc('postBase/$pollId');
    var postSnapshot = await postRef.snapshots().first;
    var post = PostEntity.fromDocumentSnapshot(postSnapshot);
    var answer = post.pollData[answerIndex];

    answer.answerResponse.add(userId);
    post.pollData[answerIndex] = answer;

    postRef.update(post.toJson());
  }
}
